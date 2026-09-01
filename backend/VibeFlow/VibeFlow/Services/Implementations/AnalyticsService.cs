using VibeFlow.DTOs.Analytics;
using VibeFlow.DTOs.Common;
using VibeFlow.Repositories.Interfaces;
using VibeFlow.Services.Interfaces;

namespace VibeFlow.Services.Implementations;

public class AnalyticsService(IAnalyticsRepository repository) : IAnalyticsService
{
    public async Task<ApiResponse<AnalyticsResponseDto>> GetAnalyticsSummaryAsync()
    {
        var sales = await repository.GetSalesRecordsAsync();
        var categorySales = await repository.GetCategorySalesRecordsAsync();
        var inventory = await repository.GetInventoryRecordsAsync();

        var dto = new AnalyticsResponseDto(
            sales.Select(s => new SalesDataDto(s.Label, s.Value)).ToList(),
            categorySales.Select(c => new CategorySalesDto(c.Category, c.Sales)).ToList(),
            inventory.Select(i => new ProductDistributionDto(i.Category, i.UnitCount)).ToList(),
            sales.Sum(s => s.Value),
            sales.Count * 18
        );

        return ApiResponse<AnalyticsResponseDto>.SuccessResult(dto);
    }
}