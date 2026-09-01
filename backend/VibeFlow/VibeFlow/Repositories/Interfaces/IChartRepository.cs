using VibeFlow.DTOs.Charts;

namespace VibeFlow.Repositories.Interfaces;

public interface IChartRepository
{
    Task<List<BasicChartPointDto>> GetBasicMonthlySalesAsync();
    Task<List<BasicChartPointDto>> GetQuarterlyPerformanceAsync();
}