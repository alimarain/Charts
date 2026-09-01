namespace VibeFlow.Api.DTOs.Auth;

public record LoginRequestDto(string Email, string Password);

public record UserResponseDto(string Id, string Name, string Email, string Role);

public record LoginResponseDto(string AccessToken, UserResponseDto User);