namespace VibeFlow.DTOs.Maker;

public record MakerProductDto(
    string Id,
    string Name,
    string Description,
    string Image,
    string Category,
    string Status,
    int FormCount
);