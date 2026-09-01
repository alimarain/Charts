using VibeFlow.DTOs.Auth;
using VibeFlow.DTOs.Common;

namespace VibeFlow.Services.Interfaces;

public interface IAuthService
{
    Task<ApiResponse<LoginResponseDto>> LoginAsync(LoginRequestDto request);
}