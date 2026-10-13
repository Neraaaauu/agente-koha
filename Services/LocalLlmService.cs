using System.Text.Json;
using System.Text.RegularExpressions;
using KohaAgentMvp.Models;
using LLama;
using LLama.Common;
using LLama.Sampling;

namespace KohaAgentMvp.Services;

public class LocalLlmService : IDisposable
{
    private readonly ILogger<LocalLlmService> _logger;
    private readonly IWebHostEnvironment _env;
    private LLamaWeights? _weights;
    private LLamaContext? _context;
    private InteractiveExecutor? _executor;
    private readonly SemaphoreSlim _semaphore = new(1, 1);
    private bool _isInitialized = false;

    public bool IsModelLoaded => _isInitialized;
    public string ModelName => "Qwen 2.5 (0.5B / 0.8B) Fine-Tuned para KOHA UABC";

    public LocalLlmService(ILogger<LocalLlmService> logger, IWebHostEnvironment env)
    {
        _logger = logger;
        _env = env;
        InitializeModel();
    }

    private void InitializeModel()
    {
        try
        {
            var modelPath = Path.Combine(_env.ContentRootPath, "models", "qwen_entrenado_koha.gguf");
            if (!File.Exists(modelPath))
            {
                modelPath = Path.Combine(_env.ContentRootPath, "Models", "qwen_entrenado_koha.gguf");
            }
            if (!File.Exists(modelPath))
            {
                _logger.LogWarning("Trained GGUF model not found at {Path}. Operating in heuristic mode.", modelPath);
                return;
            }

            _logger.LogInformation("Loading trained Qwen GGUF model from {Path}...", modelPath);
            var parameters = new ModelParams(modelPath)
            {
                ContextSize = 1024,
                GpuLayerCount = 0 // 0 capas a GPU para que corra en puro CPU sin pedir tarjeta de video dedicada
            };

            _weights = LLamaWeights.LoadFromFile(parameters);
            _context = _weights.CreateContext(parameters);
            _executor = new InteractiveExecutor(_context);
            _isInitialized = true;
            _logger.LogInformation("Trained Qwen GGUF model loaded successfully into memory!");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Could not initialize local LLM. Falling back to heuristic extractor.");
            _isInitialized = false;
        }
    }

    public async Task<SearchIntent?> ExtractIntentWithLlmAsync(string userMessage)
    {
        if (!_isInitialized || _executor == null || string.IsNullOrWhiteSpace(userMessage))
        {
            return null;
        }

        try
        {
            var prompt = $"<|im_start|>system\nEres el asistente inteligente de la Biblioteca Central Campus Mexicali (UABC). Tu función es analizar la consulta del usuario en lenguaje natural y extraer la intención y parámetros de búsqueda para la API de KOHA en formato JSON.<|im_end|>\n<|im_start|>user\n{userMessage}<|im_end|>\n<|im_start|>assistant\n";

            string responseText = string.Empty;
            await _semaphore.WaitAsync();
            try
            {
                var inferenceParams = new InferenceParams
                {
                    MaxTokens = 128,
                    SamplingPipeline = new DefaultSamplingPipeline
                    {
                        Temperature = 0.1f,
                        TopP = 0.9f
                    },
                    AntiPrompts = new List<string> { "<|im_end|>", "<|endoftext|>" }
                };

                await foreach (var text in _executor.InferAsync(prompt, inferenceParams))
                {
                    responseText += text;
                    int openCount = responseText.Count(c => c == '{');
                    int closeCount = responseText.Count(c => c == '}');
                    if (responseText.Contains("<|im_end|>") || (openCount > 0 && openCount == closeCount))
                    {
                        break;
                    }
                }
                _logger.LogInformation("LLM raw response: {Response}", responseText.Trim());
            }
            finally
            {
                _semaphore.Release();
            }

            var jsonMatch = Regex.Match(responseText, @"\{[\s\S]*\}");
            if (jsonMatch.Success)
            {
                var jsonStr = jsonMatch.Value;
                using var doc = JsonDocument.Parse(jsonStr);
                var root = doc.RootElement;

                var intent = new SearchIntent { RawQuery = userMessage };
                if (root.TryGetProperty("intencion", out var intProp))
                {
                    var intStr = intProp.GetString() ?? "";
                    if (intStr == "saludo") intent.IsGeneralGreeting = true;
                    if (intStr == "informacion_biblioteca") intent.IsLibraryInfoQuery = true;
                    if (intStr == "consultar_disponibilidad") intent.IsAvailabilityCheck = true;
                }

                if (root.TryGetProperty("parametros", out var paramsProp))
                {
                    if (paramsProp.TryGetProperty("materia", out var matProp) && matProp.ValueKind == JsonValueKind.String)
                    {
                        var mat = matProp.GetString();
                        if (!IsNoneValue(mat)) intent.Subject = mat?.Trim();
                    }

                    if (paramsProp.TryGetProperty("autor", out var autProp) && autProp.ValueKind == JsonValueKind.String)
                    {
                        var aut = autProp.GetString();
                        if (!IsNoneValue(aut)) intent.Author = aut?.Trim();
                    }

                    if (paramsProp.TryGetProperty("koha_query", out var kqProp) && kqProp.ValueKind == JsonValueKind.String)
                    {
                        var kq = kqProp.GetString();
                        if (!string.IsNullOrEmpty(kq))
                        {
                            var cleanedKq = CleanKohaQuery(kq);
                            if (!string.IsNullOrWhiteSpace(cleanedKq))
                            {
                                intent.SearchTerms = cleanedKq;
                            }
                        }
                    }
                }

                // le doy prioridad a la materia y solo meto el autor si de verdad venia en la pregunta del usuario
                if (!string.IsNullOrWhiteSpace(intent.Subject))
                {
                    if (!string.IsNullOrWhiteSpace(intent.Author) && userMessage.Contains(intent.Author, StringComparison.OrdinalIgnoreCase))
                    {
                        intent.SearchTerms = $"{intent.Author} {intent.Subject}".Trim();
                    }
                    else
                    {
                        intent.SearchTerms = intent.Subject.Trim();
                    }
                }
                else if (!string.IsNullOrWhiteSpace(intent.Author) && userMessage.Contains(intent.Author, StringComparison.OrdinalIgnoreCase))
                {
                    intent.SearchTerms = intent.Author.Trim();
                }
                else if (!string.IsNullOrWhiteSpace(intent.SearchTerms) && !IsNoneValue(intent.SearchTerms))
                {
                    intent.SearchTerms = CleanKohaQuery(intent.SearchTerms);
                }

                if (string.IsNullOrWhiteSpace(intent.SearchTerms) || IsNoneValue(intent.SearchTerms))
                {
                    intent.SearchTerms = intent.Subject ?? string.Empty;
                }

                return intent;
            }

            return null;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Error during LLM inference execution, fallback triggered.");
            return null;
        }
    }

    private static bool IsNoneValue(string? val)
    {
        if (string.IsNullOrWhiteSpace(val)) return true;
        var t = val.Trim().ToLowerInvariant();
        return t == "none" || t == "null" || t == "\"none\"" || t == "'none'" || t == "autor=none" || t == "author=none";
    }

    private static string CleanKohaQuery(string kq)
    {
        if (string.IsNullOrWhiteSpace(kq) || IsNoneValue(kq)) return string.Empty;

        // saco los terminos utiles del query que escupio el modelo
        var match = Regex.Match(kq, @"q=([^&]+)", RegexOptions.IgnoreCase);
        if (match.Success)
        {
            var val = Uri.UnescapeDataString(match.Groups[1].Value.Replace("+", " "));
            if (!IsNoneValue(val)) return val.Trim();
        }

        var authMatch = Regex.Match(kq, @"(?:author|autor)=([^&]+)", RegexOptions.IgnoreCase);
        if (authMatch.Success)
        {
            var val = Uri.UnescapeDataString(authMatch.Groups[1].Value.Replace("+", " "));
            if (!IsNoneValue(val)) return val.Trim();
        }

        var subMatch = Regex.Match(kq, @"(?:subject|materia)=([^&]+)", RegexOptions.IgnoreCase);
        if (subMatch.Success)
        {
            var val = Uri.UnescapeDataString(subMatch.Groups[1].Value.Replace("+", " "));
            if (!IsNoneValue(val)) return val.Trim();
        }

        // limpio valores nulos tipo autor=None
        var sanitized = Regex.Replace(kq, @"(?:author|autor|subject|materia|q)=(?:None|null|\b)", "", RegexOptions.IgnoreCase);
        sanitized = sanitized.Replace("+", " ").Replace("&", " ").Trim();
        return IsNoneValue(sanitized) ? string.Empty : sanitized;
    }

    public void Dispose()
    {
        _context?.Dispose();
        _weights?.Dispose();
    }
}
