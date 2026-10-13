using System.Text.RegularExpressions;
using KohaAgentMvp.Models;

namespace KohaAgentMvp.Services;

public class AgentService
{
    private readonly IKohaService _kohaService;
    private readonly LocalLlmService _llmService;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AgentService> _logger;

    public AgentService(IKohaService kohaService, LocalLlmService llmService, IConfiguration configuration, ILogger<AgentService> logger)
    {
        _kohaService = kohaService;
        _llmService = llmService;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<ChatResponse> ProcessMessageAsync(string message)
    {
        var raw = message?.Trim() ?? string.Empty;
        var normalized = NormalizeSlangAndAcronyms(raw);

        // checo si preguntan por reglamentos, horarios, prestamo o credencial
        var isLibraryInfo = Regex.IsMatch(raw, @"\b(horario|horarios|d[oó]nde est[aá]|servicios?|costos?|requisitos?|cierran|abren|a qu[eé] hora|prestamo|pr[eé]stamo|domicilio|credencial|renovaci[oó]n|multas?|sancion(es)?)\b", RegexOptions.IgnoreCase);

        var intent = await _llmService.ExtractIntentWithLlmAsync(normalized);

        if (intent == null)
        {
            intent = AnalyzeIntent(normalized);
        }
        else if (isLibraryInfo)
        {
            intent.IsLibraryInfoQuery = true;
        }
        else if (string.IsNullOrWhiteSpace(intent.SearchTerms) && !intent.IsGeneralGreeting && !intent.IsLibraryInfoQuery)
        {
            var fallback = AnalyzeIntent(normalized);
            intent.SearchTerms = fallback.SearchTerms;
            if (string.IsNullOrWhiteSpace(intent.Subject)) intent.Subject = fallback.SearchTerms;
        }

        intent.SearchTerms = SanitizeSearchTerms(intent.SearchTerms, normalized);

        var modeLabel = _llmService.IsModelLoaded
            ? $"{_kohaService.GetServiceMode()} • [Qwen 2.5 SLM Local]"
            : _kohaService.GetServiceMode();

        // si solo fue saludo devuelvo la bienvenida inicial
        if (intent.IsGeneralGreeting && string.IsNullOrWhiteSpace(intent.SearchTerms))
        {
            return new ChatResponse
            {
                Reply = "¡Hola! Soy **BiblioBot**, tu asistente inteligente de la Biblioteca Central Mexicali de la UABC. 🎓📚\n\n¿En qué puedo apoyarte hoy? Puedes pedirme recomendaciones de libros, consultar disponibilidad por materia o autor, o buscar referencias para tu proyecto de tesis o materias.",
                Books = new List<Biblio>(),
                SuggestedQuestions = new List<string>
                {
                    "¿Qué libros tienen sobre Inteligencia Artificial?",
                    "Busco libros de metodología de la investigación",
                    "¿Tienen material de redes y seguridad?",
                    "Consultar libros sobre el modelo SECI"
                },
                DetectedIntent = "Saludo General",
                Mode = modeLabel
            };
        }

        // si preguntaron por horarios o prestamos respondo directo la info
        if (intent.IsLibraryInfoQuery)
        {
            return new ChatResponse
            {
                Reply = "📍 **Biblioteca Central Mexicali - UABC**\n\n" +
                        "• **Horario:** Lunes a Viernes de 7:00 a 21:00 hrs | Sábados de 9:00 a 14:00 hrs.\n" +
                        "• **Ubicación:** Unidad Universitaria Mexicali (Campus Central).\n" +
                        "• **Préstamo en Sala:** Libre acceso para toda la comunidad universitaria.\n" +
                        "• **Préstamo a Domicilio:** Requiere credencial institucional UABC vigente de estudiante o académico (hasta 3 libros por 7 días, renovables si no hay lista de espera).\n" +
                        "• **Otros Servicios:** Módulos de consulta de catálogo KOHA, cubículos grupales y área de cómputo.\n\n" +
                        "¿Te gustaría buscar algún libro en específico del acervo?",
                Books = new List<Biblio>(),
                SuggestedQuestions = new List<string>
                {
                    "Ver libros de Inteligencia Artificial",
                    "¿Tienen libros de programación en C# y .NET?",
                    "¿Qué libros hay de Bases de Datos?"
                },
                DetectedIntent = "Información Institucional / Reglamentos",
                Mode = modeLabel
            };
        }

        // consulto el catalogo con los terminos limpios
        var maxRecommendations = _configuration.GetValue<int>("AgentSettings:MaxRecommendations", 4);
        var books = await _kohaService.SearchBibliosAsync(intent.SearchTerms, maxRecommendations);

        if (!books.Any())
        {
            return new ChatResponse
            {
                Reply = $"No encontré registros que coincidan exactamente con **\"{intent.SearchTerms}\"** en el catálogo de Biblioteca Central Mexicali. 🔍\n\nTe sugiero probar con términos más generales, verificar la ortografía o consultar por autor o materia temática.",
                Books = new List<Biblio>(),
                SuggestedQuestions = new List<string>
                {
                    "Libros de Inteligencia Artificial",
                    "Libros de Bases de Datos",
                    "Metodología de la investigación"
                },
                DetectedIntent = "Búsqueda Sin Resultados",
                Mode = modeLabel
            };
        }

        // armo la respuesta en lenguaje natural con los libros encontrados
        var responseText = GenerateNaturalReply(intent, books);

        var followups = new List<string>();
        if (books.Count > 0)
        {
            var first = books.First();
            followups.Add($"¿En qué estantería está '{first.Title}'?");
            followups.Add($"¿Tienen más títulos del autor {first.Author.Split(';').First().Trim()}?");
        }
        followups.Add("Buscar otro tema");

        return new ChatResponse
        {
            Reply = responseText,
            Books = books,
            SuggestedQuestions = followups,
            DetectedIntent = intent.IsAvailabilityCheck ? "Consulta de Disponibilidad" : "Búsqueda Temática / Bibliográfica",
            Mode = modeLabel
        };
    }

    private string GenerateNaturalReply(SearchIntent intent, List<Biblio> books)
    {
        var totalAvailable = books.Count(b => b.IsAvailable);

        var intro = intent.IsAvailabilityCheck
            ? $"Verifiqué la disponibilidad en el catálogo institucional para **\"{intent.SearchTerms}\"**:"
            : $"He consultado el catálogo de **Biblioteca Central Mexicali** y encontré **{books.Count} recurso(s)** relacionados con tu búsqueda de **\"{intent.SearchTerms}\"**:";

        var details = string.Join("\n\n", books.Select(b =>
        {
            var availBadge = b.IsAvailable
                ? $"✅ **Disponible** ({b.AvailableCount} ejemplar{(b.AvailableCount > 1 ? "es" : "")} en sala)"
                : "⚠️ **En préstamo** (Consulta con el bibliotecario)";

            var firstItem = b.Items.FirstOrDefault();
            var ubicacion = firstItem != null ? $"📍 {firstItem.Location} | Clasificación: `{firstItem.ItemCallNumber}`" : $"Clasificación: `{b.CallNumber}`";

            return $"📖 **{b.Title}**\n*Autor(es):* {b.Author} ({b.PublicationYear})\n{ubicacion}\n{availBadge}";
        }));

        var advice = "\nPuedes acudir directamente al mostrador de atención o estantería abierta con la clave de clasificación para solicitar el préstamo.";

        return $"{intro}\n\n{details}\n\n{advice}";
    }

    private SearchIntent AnalyzeIntent(string query)
    {
        var lower = query.ToLowerInvariant();
        var intent = new SearchIntent { RawQuery = query };

        // reviso si es saludo simple
        var isGreetingOnly = Regex.IsMatch(lower, @"^(hola|buen(as|os)?(\s*(d[ií]as|tardes|noches))?|saludos|que tal|qué tal)[\s!\.,?]*$");
        if (isGreetingOnly)
        {
            intent.IsGeneralGreeting = true;
            intent.SearchTerms = string.Empty;
            return intent;
        }

        if (Regex.IsMatch(lower, @"\b(hola|buen(as|os)?\s*(d[ií]as|tardes|noches)?|saludos|que tal|qué tal)\b"))
        {
            intent.IsGeneralGreeting = true;
        }

        // reviso si preguntan por horarios o info
        if (Regex.IsMatch(lower, @"\b(horario|horarios|d[oó]nde est[aá]|servicios|costo|requisitos|cierran|abren|a qu[eé] hora)\b"))
        {
            intent.IsLibraryInfoQuery = true;
        }

        // reviso si preguntan por disponibilidad fisica
        if (Regex.IsMatch(lower, @"\b(disponible|disponibilidad|prestar|quedan|hay ejemplar|ejemplares)\b"))
        {
            intent.IsAvailabilityCheck = true;
        }

        // limpio palabras comunes para quedarme con el tema principal
        var cleaned = lower;
        var stopPatterns = new[]
        {
            @"\b(hola|por favor|gracias|buenas|buenos|d[ií]as|tardes|noches)\b",
            @"\b(qu[eé]|cu[aá]l(es)?|c[oó]mo|d[oó]nde|qui[eé]n)\b",
            @"\b(busco|buscar|quiero|necesito|ocupo|me gustar[ií]a|quisiera|tienen|tienes|hay|encuentra|dime|mostrar|ver)\b",
            @"\b(libros?|informaci[oó]n|material|art[ií]culos?|documentos?|referencias?|ejemplar(es)?)\b",
            @"\b(sobre|de|del|para|en|acerca de|relacionado con|acerca)\b",
            @"\b(est[aá]|disponible|disponibilidad|en sala|en la biblioteca)\b",
            @"\b(un|una|unos|unas|el|la|los|las|al|y|o|u)\b"
        };

        foreach (var pat in stopPatterns)
        {
            cleaned = Regex.Replace(cleaned, pat, " ");
        }

        cleaned = Regex.Replace(cleaned, @"[^\w\s\d]", " ");
        cleaned = Regex.Replace(cleaned, @"\s+", " ").Trim();

        intent.SearchTerms = cleaned;
        return intent;
    }

    private string SanitizeSearchTerms(string? terms, string originalQuery)
    {
        if (string.IsNullOrWhiteSpace(terms)) return AnalyzeIntent(originalQuery).SearchTerms;

        var clean = terms;
        clean = Regex.Replace(clean, @"(?i)\b(author|autor|materia|subject|title|titulo|q)=(?:None|null|\b)", " ");
        clean = Regex.Replace(clean, @"(?i)\b(None|null)\b", " ");
        clean = clean.Replace("&", " ").Replace("+", " ").Trim();

        clean = NormalizeSlangAndAcronyms(clean);

        if (string.IsNullOrWhiteSpace(clean))
        {
            return AnalyzeIntent(originalQuery).SearchTerms;
        }

        return clean;
    }

    private static string NormalizeSlangAndAcronyms(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        var s = text;

        // 1. expando siglas comunes que usan los alumnos
        s = Regex.Replace(s, @"\b(ia|ai)\b", "inteligencia artificial", RegexOptions.IgnoreCase);
        s = Regex.Replace(s, @"\b(bd|db)\b", "bases de datos", RegexOptions.IgnoreCase);
        s = Regex.Replace(s, @"\b(poo|oop)\b", "programacion orientada a objetos", RegexOptions.IgnoreCase);
        s = Regex.Replace(s, @"\b(so|os)\b", "sistemas operativos", RegexOptions.IgnoreCase);
        s = Regex.Replace(s, @"\b(redes)\b", "redes de computadoras", RegexOptions.IgnoreCase);
        s = Regex.Replace(s, @"\b(algos)\b", "algoritmos", RegexOptions.IgnoreCase);
        s = Regex.Replace(s, @"\b(progra)\b", "programacion", RegexOptions.IgnoreCase);
        s = Regex.Replace(s, @"\b(seci)\b", "modelo seci creacion del conocimiento", RegexOptions.IgnoreCase);
        s = Regex.Replace(s, @"\b(sampieri)\b", "metodologia de la investigacion sampieri", RegexOptions.IgnoreCase);

        // 2. quito modismos y muletillas para no meter ruido al modelo
        var slangPatterns = new[]
        {
            @"\b(qu[eé]\s*onda|onda|pa|pap[aá]|carnal|we|wey|compa|bro|profe|pana|sim[oó]n|al chile|tirame|t[ií]rame)\b",
            @"\b(paro|paroza|favor|plis|please|chido|chida|rancio|rancia)\b"
        };
        foreach (var p in slangPatterns)
        {
            s = Regex.Replace(s, p, " ", RegexOptions.IgnoreCase);
        }

        return Regex.Replace(s, @"\s+", " ").Trim();
    }
}
