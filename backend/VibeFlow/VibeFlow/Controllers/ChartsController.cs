using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VibeFlow.DTOs.Charts;
using VibeFlow.DTOs.Common;
using VibeFlow.Services.Interfaces;

namespace VibeFlow.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChartsController(IChartService chartService) : ControllerBase
{
    [HttpGet("basic")]
    public async Task<ActionResult<ApiResponse<List<BasicChartPointDto>>>> GetBasicChartData()
    {
        var result = await chartService.GetBasicMonthlySalesAsync();
        return Ok(result);
    }

    [HttpGet("quarterly-performance")]
    public async Task<ActionResult<ApiResponse<List<BasicChartPointDto>>>> GetQuarterlyPerformanceAsync()
    {
        var result = await chartService.GetQuarterlyPerformanceAsync();
        return Ok(result);
    }
}