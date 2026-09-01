using VibeFlow.Entities;

namespace VibeFlow.Repositories.Interfaces;

public interface IAnalyticsRepository
{
    Task<List<SalesRecord>> GetSalesRecordsAsync();
    Task<List<CategorySalesRecord>> GetCategorySalesRecordsAsync();
    Task<List<ProductInventoryRecord>> GetInventoryRecordsAsync();
}