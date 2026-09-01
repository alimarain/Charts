namespace VibeFlow.DTOs.Maker;

public record FormFieldDto(
    string Id,
    string Label,
    string Key,
    string Type,
    bool Required,
    List<string> Options
);