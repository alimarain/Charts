using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VibeFlow.DTOs.Common;
using VibeFlow.DTOs.Maker;
using VibeFlow.Services.Interfaces;

namespace VibeFlow.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "maker")]
public class MakerController(IMakerService makerService) : ControllerBase
{
    [HttpGet("products")]
    public async Task<ActionResult<ApiResponse<List<MakerProductDto>>>> GetProducts()
    {
        var result = await makerService.GetProductsAsync();
        return Ok(result);
    }

    [HttpGet("products/{productId}/forms")]
    public async Task<ActionResult<ApiResponse<List<MakerFormDto>>>> GetForms(string productId)
    {
        var result = await makerService.GetFormsByProductAsync(productId);
        return Ok(result);
    }

    [HttpGet("forms/{formId}/fields")]
    public async Task<ActionResult<ApiResponse<List<FormFieldDto>>>> GetFields(string formId)
    {
        var result = await makerService.GetFieldsByFormAsync(formId);
        if (!result.Success) return NotFound(result);
        return Ok(result);
    }

    [HttpPost("forms/{formId}/submit")]
    public async Task<ActionResult<ApiResponse<SubmitApplicationResponseDto>>> Submit(
        string formId,
        [FromBody] SubmitApplicationRequestDto request)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;
        var result = await makerService.SubmitApplicationAsync(formId, userId, request);
        if (!result.Success) return BadRequest(result);
        return Ok(result);
    }
}