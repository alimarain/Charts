using VibeFlow.DTOs.Charts;
using VibeFlow.Repositories.Interfaces;

namespace VibeFlow.Repositories.Implementations;

public class ChartRepository : IChartRepository
{
    public Task<List<BasicChartPointDto>> GetBasicMonthlySalesAsync()
    {
        var data = new List<BasicChartPointDto>
        {
            new("Jan", 14500, "#00F2FE", "+8%"),
            new("Feb", 21200, "#38BDF8", "+16%"),
            new("Mar", 18400, "#6366F1", "-3%"),
            new("Apr", 27800, "#8B5CF6", "+24%"),
            new("May", 23600, "#A855F7", "+11%"),
            new("Jun", 31500, "#10B981", "+32%")
        };

        return Task.FromResult(data);
    }

    public Task<List<BasicChartPointDto>> GetQuarterlyPerformanceAsync()
    {
        var data = new List<BasicChartPointDto>
        {
            new("Sprint 1", 15000, "#00F2FE", "Baseline"),
            new("Sprint 2", 22000, "#38BDF8", "+46%"),
            new("Sprint 3", 22000, "#6366F1", "Sustained"),
            new("Sprint 4", 34000, "#8B5CF6", "+54%"),
            new("Sprint 5", 34000, "#A855F7", "Sustained"),
            new("Sprint 6", 48000, "#10B981", "+41%")
        };

        return Task.FromResult(data);
    }
}