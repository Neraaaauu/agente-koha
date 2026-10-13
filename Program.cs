using KohaAgentMvp.Models;
using KohaAgentMvp.Services;

var builder = WebApplication.CreateBuilder(args);

// si no tenemos las credenciales de Koha todavia, usamos el mock local para pruebas
var useMock = builder.Configuration.GetValue<bool>("UseMock", true);

if (useMock)
{
    builder.Services.AddSingleton<IKohaService, KohaMockService>();
}
else
{
    builder.Services.AddHttpClient<KohaApiClient>();
    builder.Services.AddSingleton<IKohaService, KohaApiClient>();
}

builder.Services.AddSingleton<LocalLlmService>();
builder.Services.AddScoped<AgentService>();

// habilito cors por si consumo el api desde otra ip o puerto
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();
    });
});

var app = builder.Build();

app.UseCors();
app.UseDefaultFiles();
app.UseStaticFiles();

// endpoint principal del chat
app.MapPost("/api/chat", async (ChatRequest request, AgentService agent) =>
{
    if (string.IsNullOrWhiteSpace(request?.Message))
    {
        return Results.BadRequest(new { error = "El mensaje no puede estar vacío." });
    }

    var response = await agent.ProcessMessageAsync(request.Message);
    return Results.Ok(response);
});

// busqueda directa al catalogo sin pasar por el modelo
app.MapPost("/api/catalog/search", async (CatalogSearchQuery searchReq, IKohaService kohaService) =>
{
    var q = searchReq.Query ?? string.Empty;
    var limit = searchReq.Limit > 0 ? searchReq.Limit : 10;
    var results = await kohaService.SearchBibliosAsync(q, limit);
    return Results.Ok(new
    {
        query = q,
        count = results.Count,
        results = results,
        mode = kohaService.GetServiceMode()
    });
});

// endpoint de status para revisar si el modelo y el servicio levantaron bien
app.MapGet("/api/status", async (IKohaService kohaService, LocalLlmService localLlm, IConfiguration config) =>
{
    var total = await kohaService.GetTotalCountAsync();
    return Results.Ok(new
    {
        service = "Agente Inteligente Biblioteca Central Mexicali",
        institution = "UABC - Facultad de Ciencias de la Ingeniería y Tecnología",
        status = "En línea",
        timestamp = DateTime.UtcNow,
        mode = kohaService.GetServiceMode(),
        isMockMode = config.GetValue<bool>("UseMock", true),
        isLlmActive = localLlm.IsModelLoaded,
        llmModel = localLlm.IsModelLoaded ? localLlm.ModelName : "Modo Heurístico / Extracción NLP",
        kohaBaseUrl = config["KohaApi:BaseUrl"],
        indexedRecords = total
    });
});

app.Run("http://localhost:5000");

public record CatalogSearchQuery(string? Query, int Limit = 10);
