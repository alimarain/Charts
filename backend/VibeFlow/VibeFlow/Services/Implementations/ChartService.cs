using VibeFlow.DTOs.Charts;
using VibeFlow.DTOs.Common;
using VibeFlow.Repositories.Interfaces;
using VibeFlow.Services.Interfaces;

namespace VibeFlow.Services.Implementations;

public class ChartService(IChartRepository repository) : IChartService
{
    public async Task<ApiResponse<List<BasicChartPointDto>>> GetBasicMonthlySalesAsync()
    {
        var data = await repository.GetBasicMonthlySalesAsync();
        return ApiResponse<List<BasicChartPointDto>>.SuccessResult(data);
    }

    public async Task<ApiResponse<List<BasicChartPointDto>>> GetQuarterlyPerformanceAsync()
    {
        var data = await repository.GetQuarterlyPerformanceAsync();
        return ApiResponse<List<BasicChartPointDto>>.SuccessResult(data);
    }
}