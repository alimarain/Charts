namespace VibeFlow.DTOs.Maker;

public record MakerFormDto(
    string Id,
    string Name,
    string Description,
    int FieldCount
);