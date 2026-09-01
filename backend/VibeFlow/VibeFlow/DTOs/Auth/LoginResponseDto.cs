namespace VibeFlow.DTOs.Auth;

public record LoginResponseDto(string AccessToken, UserResponseDto User);