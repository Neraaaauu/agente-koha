using System.Globalization;
using System.Text;
using System.Text.Json;
using KohaAgentMvp.Models;

namespace KohaAgentMvp.Services;

public class KohaMockService : IKohaService
{
    private readonly List<Biblio> _catalog;

    public KohaMockService()
    {
        _catalog = LoadMockCatalog();
    }

    private List<Biblio> LoadMockCatalog()
    {
        // cargo el catalogo mock con los libros del acervo oficial
        var candidates = new[]
        {
            Path.Combine(Directory.GetCurrentDirectory(), "catalog_mock.json"),
            Path.Combine(AppContext.BaseDirectory, "catalog_mock.json"),
            Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "catalog_mock.json")
        };

        foreach (var path in candidates)
        {
            if (File.Exists(path))
            {
                try
                {
                    var json = File.ReadAllText(path, Encoding.UTF8);
                    var books = JsonSerializer.Deserialize<List<Biblio>>(json);
                    if (books != null && books.Count > 0)
                    {
                        return books;
                    }
                }
                catch
                {
                    // si llega a tronar por algo, uso el catalogo base de respaldo
                }
            }
        }

        return GetDefaultCatalog();
    }

    public Task<List<Biblio>> SearchBibliosAsync(string query, int limit = 5)
    {
        if (string.IsNullOrWhiteSpace(query))
        {
            return Task.FromResult(_catalog.Take(limit).ToList());
        }

        var normalized = NormalizeText(query);
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

        // si no hubo match estricto por puntuacion, hago un barrido flexible
        if (!matches.Any())
        {
            matches = _catalog
                .Where(b => NormalizeText(b.Subject ?? "").Contains(normalized) ||
                            NormalizeText(b.Title).Contains(normalized) ||
                            NormalizeText(b.Author).Contains(normalized))
                .Take(limit)
                .ToList();
        }

        return Task.FromResult(matches);
    }

    private static int CalculateScore(Biblio b, string fullQuery, List<string> terms)
    {
        int score = 0;
        var title = NormalizeText(b.Title);
        var author = NormalizeText(b.Author);
        var subject = NormalizeText(b.Subject ?? string.Empty);
        var abstractText = NormalizeText(b.Abstract ?? string.Empty);

        if (title.Contains(fullQuery)) score += 80;
        if (subject.Contains(fullQuery)) score += 50;
        if (author.Contains(fullQuery)) score += 60;

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
                    score += 45;
                    termMatched = true;
                    nonGenericMatches++;
                }
            }
            if (term == "bd" || term == "db")
            {
                if (title.Contains("bases de datos") || subject.Contains("bases de datos"))
                {
                    score += 45;
                    termMatched = true;
                    nonGenericMatches++;
                }
            }
            if (term == "poo" || term == "oop")
            {
                if (title.Contains("orientada a objetos") || subject.Contains("orientada a objetos"))
                {
                    score += 45;
                    termMatched = true;
                    nonGenericMatches++;
                }
            }

            var stem = term.Length > 5 ? term.Substring(0, term.Length - 2) : term;
            if (title.Contains(term) || (term.Length > 5 && title.Contains(stem)))
            {
                score += 20;
                termMatched = true;
            }
            if (subject.Contains(term) || (term.Length > 5 && subject.Contains(stem)))
            {
                score += 15;
                termMatched = true;
            }
            if (author.Contains(term) || (term.Length > 5 && author.Contains(stem)))
            {
                score += 18;
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

        if (terms.Count > 1 && nonGenericMatches == 0)
        {
            return 0;
        }

        // si la consulta trae varias palabras, le doy mas peso a que coincidan varios terminos
        if (matchedTermsCount > 1)
        {
            score += matchedTermsCount * 35;
        }

        return score;
    }

    private static string NormalizeText(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        var normalized = text.Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder();
        foreach (var c in normalized)
        {
            var category = CharUnicodeInfo.GetUnicodeCategory(c);
            if (category != UnicodeCategory.NonSpacingMark)
            {
                sb.Append(c);
            }
        }
        return sb.ToString().Normalize(NormalizationForm.FormC).ToLowerInvariant().Trim();
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

    private static List<Biblio> GetDefaultCatalog()
    {
        return new List<Biblio>
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
                    new Item { ItemId = 1001, Barcode = "UABC-BCM-019283", HoldingLibrary = "Biblioteca Central Mexicali", Location = "Colección General - Planta Alta (Estante 14-B)", ItemCallNumber = "Q335 .R87 2021 c.1", Status = "Disponible" }
                }
            }
        };
    }
}
