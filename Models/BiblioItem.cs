using System.Text.Json.Serialization;

namespace KohaAgentMvp.Models;

public class Biblio
{
    [JsonPropertyName("biblio_id")]
    public int BiblioId { get; set; }

    [JsonPropertyName("title")]
    public string Title { get; set; } = string.Empty;

    [JsonPropertyName("author")]
    public string Author { get; set; } = string.Empty;

    [JsonPropertyName("isbn")]
    public string? Isbn { get; set; }

    [JsonPropertyName("publication_year")]
    public string? PublicationYear { get; set; }

    [JsonPropertyName("publisher")]
    public string? Publisher { get; set; }

    [JsonPropertyName("abstract")]
    public string? Abstract { get; set; }

    [JsonPropertyName("call_number")]
    public string? CallNumber { get; set; }

    [JsonPropertyName("subject")]
    public string? Subject { get; set; }

    [JsonPropertyName("cover_url")]
    public string? CoverUrl { get; set; }

    [JsonPropertyName("items")]
    public List<Item> Items { get; set; } = new();

    [JsonIgnore]
    public bool IsAvailable => Items.Any(i => i.Status.Equals("Disponible", StringComparison.OrdinalIgnoreCase));

    [JsonIgnore]
    public int AvailableCount => Items.Count(i => i.Status.Equals("Disponible", StringComparison.OrdinalIgnoreCase));
}

public class Item
{
    [JsonPropertyName("item_id")]
    public int ItemId { get; set; }

    [JsonPropertyName("barcode")]
    public string Barcode { get; set; } = string.Empty;

    [JsonPropertyName("holding_library")]
    public string HoldingLibrary { get; set; } = "Biblioteca Central Mexicali";

    [JsonPropertyName("location")]
    public string Location { get; set; } = "Colección General - Estantería Abierta";

    [JsonPropertyName("item_call_number")]
    public string ItemCallNumber { get; set; } = string.Empty;

    [JsonPropertyName("status")]
    public string Status { get; set; } = "Disponible"; // "Disponible", "En préstamo", "En consulta"
}

public class ChatRequest
{
    [JsonPropertyName("message")]
    public string Message { get; set; } = string.Empty;

    [JsonPropertyName("sessionId")]
    public string? SessionId { get; set; }
}

public class ChatResponse
{
    [JsonPropertyName("reply")]
    public string Reply { get; set; } = string.Empty;

    [JsonPropertyName("books")]
    public List<Biblio> Books { get; set; } = new();

    [JsonPropertyName("suggestedQuestions")]
    public List<string> SuggestedQuestions { get; set; } = new();

    [JsonPropertyName("detectedIntent")]
    public string DetectedIntent { get; set; } = string.Empty;

    [JsonPropertyName("mode")]
    public string Mode { get; set; } = "Sandbox (Koha Schema Mock)";
}

public class SearchIntent
{
    public string RawQuery { get; set; } = string.Empty;
    public string SearchTerms { get; set; } = string.Empty;
    public string? Author { get; set; }
    public string? Subject { get; set; }
    public bool IsAvailabilityCheck { get; set; }
    public bool IsGeneralGreeting { get; set; }
    public bool IsLibraryInfoQuery { get; set; }
}
