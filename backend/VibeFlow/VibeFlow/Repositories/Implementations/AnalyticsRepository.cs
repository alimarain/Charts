using Microsoft.EntityFrameworkCore;
using VibeFlow.Data;
using VibeFlow.Entities;
using VibeFlow.Repositories.Interfaces;

namespace VibeFlow.Repositories.Implementations;

public class AnalyticsRepository(ApplicationDbContext context) : IAnalyticsRepository
{
    public async Task<List<SalesRecord>> GetSalesRecordsAsync() =>
        await context.SalesRecords.AsNoTracking().ToListAsync();

    public async Task<List<CategorySalesRecord>> GetCategorySalesRecordsAsync() =>
        await context.CategorySalesRecords.AsNoTracking().ToListAsync();

    public async Task<List<ProductInventoryRecord>> GetInventoryRecordsAsync() =>
        await context.ProductInventoryRecords.AsNoTracking().ToListAsync();
}