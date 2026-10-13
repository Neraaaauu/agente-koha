using System.Net.Http.Headers;
using System.Text.Json;
using System.Text.Json.Serialization;
using KohaAgentMvp.Models;

namespace KohaAgentMvp.Services;

public class KohaApiClient : IKohaService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly ILogger<KohaApiClient> _logger;
    private string? _cachedToken;
    private DateTime _tokenExpiration = DateTime.MinValue;

    public KohaApiClient(HttpClient httpClient, IConfiguration configuration, ILogger<KohaApiClient> logger)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<List<Biblio>> SearchBibliosAsync(string query, int limit = 5)
    {
        try
        {
            var token = await GetValidTokenAsync();
            var baseUrl = _configuration["KohaApi:BaseUrl"] ?? "https://kohaadminpruebas.uabc.mx/api/v1";
            
            var request = new HttpRequestMessage(HttpMethod.Get, $"{baseUrl}/biblios?q={Uri.EscapeDataString(query)}&_per_page={limit}");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            var response = await _httpClient.SendAsync(request);
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                var results = JsonSerializer.Deserialize<List<Biblio>>(content);
                return results ?? new List<Biblio>();
            }

            _logger.LogWarning("Koha API responded with status {StatusCode}", response.StatusCode);
            return new List<Biblio>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error communicating with Koha REST API");
            return new List<Biblio>();
        }
    }

    public async Task<Biblio?> GetBiblioByIdAsync(int biblioId)
    {
        try
        {
            var token = await GetValidTokenAsync();
            var baseUrl = _configuration["KohaApi:BaseUrl"] ?? "https://kohaadminpruebas.uabc.mx/api/v1";

            var request = new HttpRequestMessage(HttpMethod.Get, $"{baseUrl}/biblios/{biblioId}");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

            var response = await _httpClient.SendAsync(request);
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<Biblio>(content);
            }
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching biblio {BiblioId} from Koha API", biblioId);
            return null;
        }
    }

    public Task<int> GetTotalCountAsync()
    {
        return Task.FromResult(0);
    }

    public string GetServiceMode()
    {
        return "Producción / Pruebas UABC (Koha Live REST API)";
    }

    private async Task<string> GetValidTokenAsync()
    {
        if (!string.IsNullOrEmpty(_cachedToken) && DateTime.UtcNow < _tokenExpiration)
        {
            return _cachedToken;
        }

        var tokenUrl = _configuration["KohaApi:TokenUrl"] ?? "https://kohaadminpruebas.uabc.mx/api/v1/oauth/token";
        var clientId = _configuration["KohaApi:ClientId"] ?? string.Empty;
        var clientSecret = _configuration["KohaApi:ClientSecret"] ?? string.Empty;

        var dict = new Dictionary<string, string>
        {
            { "grant_type", "client_credentials" },
            { "client_id", clientId },
            { "client_secret", clientSecret }
        };

        var response = await _httpClient.PostAsync(tokenUrl, new FormUrlEncodedContent(dict));
        response.EnsureSuccessStatusCode();

        var json = await response.Content.ReadAsStringAsync();
        var tokenObj = JsonSerializer.Deserialize<KohaTokenResponse>(json);

        _cachedToken = tokenObj?.AccessToken ?? string.Empty;
        _tokenExpiration = DateTime.UtcNow.AddSeconds((tokenObj?.ExpiresIn ?? 3600) - 60);

        return _cachedToken;
    }

    private class KohaTokenResponse
    {
        [JsonPropertyName("access_token")]
        public string AccessToken { get; set; } = string.Empty;

        [JsonPropertyName("expires_in")]
        public int ExpiresIn { get; set; } = 3600;

        [JsonPropertyName("token_type")]
        public string TokenType { get; set; } = "Bearer";
    }
}
