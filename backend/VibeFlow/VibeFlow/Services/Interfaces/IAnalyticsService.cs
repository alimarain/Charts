using VibeFlow.DTOs.Analytics;
using VibeFlow.DTOs.Common;

namespace VibeFlow.Services.Interfaces;

public interface IAnalyticsService
{
    Task<ApiResponse<AnalyticsResponseDto>> GetAnalyticsSummaryAsync();
}