using KohaAgentMvp.Models;

namespace KohaAgentMvp.Services;

public class KohaMockService : IKohaService
{
    private readonly List<Biblio> _catalog;

    public KohaMockService()
    {
        _catalog = new List<Biblio>
        {
            new Biblio
            {
                BiblioId = 101,
                Title = "Inteligencia Artificial: Un Enfoque Moderno",
                Author = "Russell, Stuart; Norvig, Peter",
                Isbn = "978-8448171377",
                PublicationYear = "2021",
                Publisher = "Pearson Educación",
                CallNumber = "Q335 .R87 2021",
                Subject = "Inteligencia Artificial, Agentes Inteligentes, Búsqueda Heurística, Aprendizaje Automático",
                Abstract = "El texto de referencia fundamental a nivel universitario en IA. Cubre desde agentes reactivos y basados en metas, representación del conocimiento, hasta aprendizaje profundo y procesamiento de lenguaje natural.",
                CoverUrl = "https://images.unsplash.com/photo-1677442136019-21780efad99a?w=300&auto=format&fit=crop&q=80",
                Items = new List<Item>
                {
                    new Item { ItemId = 1001, Barcode = "UABC-BCM-019283", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Alta (Estante 14-B)", ItemCallNumber = "Q335 .R87 2021 c.1", Status = "Disponible" },
                    new Item { ItemId = 1002, Barcode = "UABC-BCM-019284", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Alta (Estante 14-B)", ItemCallNumber = "Q335 .R87 2021 c.2", Status = "Disponible" },
                    new Item { ItemId = 1003, Barcode = "UABC-BCM-019285", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Área de Reserva", ItemCallNumber = "Q335 .R87 2021 c.3", Status = "En préstamo" }
                }
            },
            new Biblio
            {
                BiblioId = 102,
                Title = "Deep Learning: Algoritmos y Aplicaciones Prácticas",
                Author = "Goodfellow, Ian; Bengio, Yoshua; Courville, Aaron",
                Isbn = "978-0262035613",
                PublicationYear = "2019",
                Publisher = "MIT Press / Reverté",
                CallNumber = "QA76.87 .G66 2019",
                Subject = "Redes Neuronales, Deep Learning, Inteligencia Artificial, Visión por Computadora, NLP",
                Abstract = "Obra cumbre sobre aprendizaje profundo escrita por pioneros del campo. Describe matemáticas de optimización, redes convolucionales, recurrentes y modelos generativos.",
                CoverUrl = "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=300&auto=format&fit=crop&q=80",
                Items = new List<Item>
                {
                    new Item { ItemId = 1004, Barcode = "UABC-BCM-024512", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Alta (Estante 15-A)", ItemCallNumber = "QA76.87 .G66 2019 c.1", Status = "Disponible" },
                    new Item { ItemId = 1005, Barcode = "UABC-BCM-024513", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Alta (Estante 15-A)", ItemCallNumber = "QA76.87 .G66 2019 c.2", Status = "En préstamo" }
                }
            },
            new Biblio
            {
                BiblioId = 103,
                Title = "Redes de Computadoras: Arquitectura, Protocolos y Seguridad",
                Author = "Tanenbaum, Andrew S.; Wetherall, David J.",
                Isbn = "978-6073214452",
                PublicationYear = "2020",
                Publisher = "Pearson Educación",
                CallNumber = "TK5105.5 .T36 2020",
                Subject = "Redes de Computadoras, Protocolos de Comunicación, TCP/IP, Seguridad Informática",
                Abstract = "Guía completa que abarca la pila OSI y TCP/IP, desde la capa física hasta la capa de aplicación, protocolos HTTP/REST y redes inalámbricas modernas.",
                CoverUrl = "https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=300&auto=format&fit=crop&q=80",
                Items = new List<Item>
                {
                    new Item { ItemId = 1006, Barcode = "UABC-BCM-008741", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Alta (Estante 18-C)", ItemCallNumber = "TK5105.5 .T36 2020 c.1", Status = "Disponible" },
                    new Item { ItemId = 1007, Barcode = "UABC-BCM-008742", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Alta (Estante 18-C)", ItemCallNumber = "TK5105.5 .T36 2020 c.2", Status = "Disponible" }
                }
            },
            new Biblio
            {
                BiblioId = 104,
                Title = "Fundamentos de Sistemas de Bases de Datos",
                Author = "Silberschatz, Abraham; Korth, Henry F.; Sudarshan, S.",
                Isbn = "978-6071512536",
                PublicationYear = "2021",
                Publisher = "McGraw-Hill",
                CallNumber = "QA76.9.D3 .S55 2021",
                Subject = "Bases de Datos, SQL, Modelo Relacional, Normalización, Redundancia, NoSQL, Transacciones y Concurrencia",
                Abstract = "Conceptos esenciales de gestión de datos, diseño de modelos entidad-relación, normalización de tablas para eliminar redundancia, álgebra relacional, SQL y optimización de consultas.",
                CoverUrl = "https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=300&auto=format&fit=crop&q=80",
                Items = new List<Item>
                {
                    new Item { ItemId = 1008, Barcode = "UABC-BCM-031120", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Alta (Estante 16-D)", ItemCallNumber = "QA76.9.D3 .S55 2021 c.1", Status = "Disponible" }
                }
            },
            new Biblio
            {
                BiblioId = 105,
                Title = "Metodología de la Investigación: Las Rutas Cuantitativa, Cualitativa y Mixta",
                Author = "Hernández Sampieri, Roberto; Mendoza Torres, Christian",
                Isbn = "978-1456260965",
                PublicationYear = "2018",
                Publisher = "McGraw-Hill Interamericana",
                CallNumber = "Q180.55.M4 .H47 2018",
                Subject = "Metodología de la Investigación, Tesis, Epistemología, Instrumentos de Medición",
                Abstract = "Obra indispensable para el desarrollo de proyectos terminales de posgrado y tesis de maestría. Explica el planteamiento del problema, marco metodológico e instrumentos de recolección.",
                CoverUrl = "https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=300&auto=format&fit=crop&q=80",
                Items = new List<Item>
                {
                    new Item { ItemId = 1009, Barcode = "UABC-BCM-045519", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Baja (Estante 03-A)", ItemCallNumber = "Q180.55.M4 .H47 2018 c.1", Status = "Disponible" },
                    new Item { ItemId = 1010, Barcode = "UABC-BCM-045520", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Baja (Estante 03-A)", ItemCallNumber = "Q180.55.M4 .H47 2018 c.2", Status = "En préstamo" }
                }
            },
            new Biblio
            {
                BiblioId = 106,
                Title = "La Creación del Conocimiento en la Organización: El Modelo SECI",
                Author = "Nonaka, Ikujiro; Takeuchi, Hirotaka",
                Isbn = "978-9681858025",
                PublicationYear = "2019",
                Publisher = "Oxford University Press México",
                CallNumber = "HD30.2 .N66 2019",
                Subject = "Gestión del Conocimiento, Modelo SECI, Aprendizaje Organizacional, Innovación",
                Abstract = "Texto de soporte fundamental para la Maestría en Tecnologías para el Aprendizaje Organizacional. Describe la espiral del conocimiento: Socialización, Exteriorización, Combinación e Interiorización.",
                CoverUrl = "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300&auto=format&fit=crop&q=80",
                Items = new List<Item>
                {
                    new Item { ItemId = 1011, Barcode = "UABC-BCM-051280", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección Posgrado / Humanidades (Estante 07-C)", ItemCallNumber = "HD30.2 .N66 2019 c.1", Status = "Disponible" }
                }
            },
            new Biblio
            {
                BiblioId = 107,
                Title = "Desarrollo de Soluciones Web con ASP.NET Core y C#",
                Author = "Deitel, Paul; Deitel, Harvey",
                Isbn = "978-0137525492",
                PublicationYear = "2022",
                Publisher = "Pearson Educación",
                CallNumber = "QA76.73.C154 .D45 2022",
                Subject = "C#, .NET, ASP.NET Core, Programación Orientada a Objetos, Servicios Web REST",
                Abstract = "Enfoque integral para el desarrollo de APIs y servicios web multiplataforma con C# y .NET, inyección de dependencias, seguridad y middleware.",
                CoverUrl = "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=300&auto=format&fit=crop&q=80",
                Items = new List<Item>
                {
                    new Item { ItemId = 1012, Barcode = "UABC-BCM-060411", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Alta (Estante 17-B)", ItemCallNumber = "QA76.73.C154 .D45 2022 c.1", Status = "Disponible" }
                }
            },
            new Biblio
            {
                BiblioId = 108,
                Title = "Python para Análisis de Datos y Aprendizaje de Máquina",
                Author = "McKinney, Wes",
                Isbn = "978-8441544499",
                PublicationYear = "2023",
                Publisher = "Anaya Multimedia",
                CallNumber = "QA76.73.P98 .M35 2023",
                Subject = "Python, Manipulación de Datos, Pandas, NumPy, Machine Learning",
                Abstract = "Manual práctico por el creador de la biblioteca Pandas. Aborda carga de datos, limpieza, estructuración, análisis exploratorio y visualización.",
                CoverUrl = "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=300&auto=format&fit=crop&q=80",
                Items = new List<Item>
                {
                    new Item { ItemId = 1013, Barcode = "UABC-BCM-063991", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Alta (Estante 17-E)", ItemCallNumber = "QA76.73.P98 .M35 2023 c.1", Status = "Disponible" }
                }
            }
        };
    }

    public Task<List<Biblio>> SearchBibliosAsync(string query, int limit = 5)
    {
        if (string.IsNullOrWhiteSpace(query))
        {
            return Task.FromResult(_catalog.Take(limit).ToList());
        }

        var normalized = query.ToLowerInvariant().Trim();
        var terms = normalized.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                             .Where(t => t.Length >= 2)
                             .ToList();

        if (!terms.Any())
        {
            terms.Add(normalized);
        }

        var matches = _catalog
            .Select(b => new
            {
                Biblio = b,
                Score = CalculateScore(b, normalized, terms)
            })
            .Where(x => x.Score > 0)
            .OrderByDescending(x => x.Score)
            .Take(limit)
            .Select(x => x.Biblio)
            .ToList();

        // si no hubo match estricto, hago un fallback buscando coincidencia en materia o titulo
        if (!matches.Any())
        {
            matches = _catalog
                .Where(b => (b.Subject?.ToLowerInvariant().Contains(normalized) ?? false) ||
                            (b.Title.ToLowerInvariant().Contains(normalized)))
                .Take(limit)
                .ToList();
        }

        return Task.FromResult(matches);
    }

    private static int CalculateScore(Biblio b, string fullQuery, List<string> terms)
    {
        int score = 0;
        var title = b.Title.ToLowerInvariant();
        var author = b.Author.ToLowerInvariant();
        var subject = (b.Subject ?? string.Empty).ToLowerInvariant();
        var abstractText = (b.Abstract ?? string.Empty).ToLowerInvariant();

        if (title.Contains(fullQuery)) score += 60;
        if (subject.Contains(fullQuery)) score += 40;
        if (author.Contains(fullQuery)) score += 50;

        var genericModifiers = new HashSet<string> { "moderno", "moderna", "enfoque", "fundamentos", "introduccion", "practico", "practica", "general", "avanzado", "avanzada", "principios", "analisis", "guia" };

        int matchedTermsCount = 0;
        int nonGenericMatches = 0;

        foreach (var term in terms)
        {
            bool termMatched = false;

            if (term == "ia" || term == "ai")
            {
                if (title.Contains("inteligencia artificial") || subject.Contains("inteligencia artificial"))
                {
                    score += 40;
                    termMatched = true;
                    nonGenericMatches++;
                }
            }
            if (term == "bd" || term == "db")
            {
                if (title.Contains("bases de datos") || subject.Contains("bases de datos"))
                {
                    score += 40;
                    termMatched = true;
                    nonGenericMatches++;
                }
            }
            if (term == "poo" || term == "oop")
            {
                if (title.Contains("orientada a objetos") || subject.Contains("orientada a objetos"))
                {
                    score += 40;
                    termMatched = true;
                    nonGenericMatches++;
                }
            }

            var stem = term.Length > 5 ? term.Substring(0, term.Length - 2) : term;
            if (title.Contains(term) || (term.Length > 5 && title.Contains(stem)))
            {
                score += 15;
                termMatched = true;
            }
            if (subject.Contains(term) || (term.Length > 5 && subject.Contains(stem)))
            {
                score += 12;
                termMatched = true;
            }
            if (author.Contains(term) || (term.Length > 5 && author.Contains(stem)))
            {
                score += 14;
                termMatched = true;
            }
            if (abstractText.Contains(term) || (term.Length > 5 && abstractText.Contains(stem)))
            {
                score += 5;
                termMatched = true;
            }

            if (termMatched)
            {
                matchedTermsCount++;
                if (!genericModifiers.Contains(term))
                {
                    nonGenericMatches++;
                }
            }
        }

        // evito falsos positivos: si buscaron "arte moderno", no debe dar match solo por la palabra "moderno"
        if (terms.Count > 1 && nonGenericMatches == 0)
        {
            return 0;
        }

        // si son varias palabras y no es frase exacta, pido que coincidan al menos dos
        if (terms.Count > 1 && matchedTermsCount < 2 && !title.Contains(fullQuery) && !subject.Contains(fullQuery))
        {
            return 0;
        }

        return score;
    }

    public Task<Biblio?> GetBiblioByIdAsync(int biblioId)
    {
        var item = _catalog.FirstOrDefault(b => b.BiblioId == biblioId);
        return Task.FromResult(item);
    }

    public Task<int> GetTotalCountAsync()
    {
        return Task.FromResult(_catalog.Count);
    }

    public string GetServiceMode()
    {
        return "Sandbox (Koha Schema Mock - Biblioteca Central Mexicali)";
    }
}
