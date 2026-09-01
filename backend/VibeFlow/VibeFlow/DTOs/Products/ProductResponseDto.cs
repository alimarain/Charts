namespace VibeFlow.DTOs.Products;

public record ProductResponseDto(
    string Id,
    string Name,
    string Description,
    string ImageUrl,
    string Category,
    string Status
);