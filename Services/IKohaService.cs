using KohaAgentMvp.Models;

namespace KohaAgentMvp.Services;

public interface IKohaService
{
    Task<List<Biblio>> SearchBibliosAsync(string query, int limit = 5);
    Task<Biblio?> GetBiblioByIdAsync(int biblioId);
    Task<int> GetTotalCountAsync();
    string GetServiceMode();
}
