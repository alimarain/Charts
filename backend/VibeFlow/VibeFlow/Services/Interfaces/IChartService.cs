using VibeFlow.DTOs.Charts;
using VibeFlow.DTOs.Common;

namespace VibeFlow.Services.Interfaces;

public interface IChartService
{
    Task<ApiResponse<List<BasicChartPointDto>>> GetBasicMonthlySalesAsync();
    Task<ApiResponse<List<BasicChartPointDto>>> GetQuarterlyPerformanceAsync();
}