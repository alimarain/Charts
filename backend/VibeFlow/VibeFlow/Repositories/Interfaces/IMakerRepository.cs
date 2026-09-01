using VibeFlow.Entities;

namespace VibeFlow.Repositories.Interfaces;

public interface IMakerRepository
{
    Task<List<Product>> GetMakerProductsWithFormCountsAsync();
    Task<List<Form>> GetFormsByProductIdAsync(string productId);
    Task<Form?> GetFormWithFieldsAsync(string formId);
    Task<string> SubmitApplicationTransactionAsync(ApplicationSubmission submission, List<ApplicationAnswer> answers);
}