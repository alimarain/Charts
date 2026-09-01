using Microsoft.AspNetCore.Mvc;
using VibeFlow.DTOs.Auth;
using VibeFlow.DTOs.Common;
using VibeFlow.Services.Interfaces;

namespace VibeFlow.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(IAuthService authService) : ControllerBase
{
    [HttpPost("login")]
    public async Task<ActionResult<ApiResponse<LoginResponseDto>>> Login([FromBody] LoginRequestDto request)
    {
        var result = await authService.LoginAsync(request);
        if (!result.Success) return Unauthorized(result);
        return Ok(result);
    }
}