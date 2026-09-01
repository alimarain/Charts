namespace VibeFlow.DTOs.Charts;

public record BasicChartPointDto(
    string Month,
    double Sales,
    string ColorHex,
    string GrowthTag
);