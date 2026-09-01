using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VibeFlow.DTOs.Analytics;
using VibeFlow.DTOs.Common;
using VibeFlow.Services.Interfaces;

namespace VibeFlow.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "user,maker")]
public class AnalyticsController(IAnalyticsService analyticsService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ApiResponse<AnalyticsResponseDto>>> GetAnalytics()
    {
        var result = await analyticsService.GetAnalyticsSummaryAsync();
        return Ok(result);
    }
}