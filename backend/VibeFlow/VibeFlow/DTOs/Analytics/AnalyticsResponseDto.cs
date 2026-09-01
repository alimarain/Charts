namespace VibeFlow.DTOs.Analytics;

public record AnalyticsResponseDto(
    List<SalesDataDto> SalesData,
    List<CategorySalesDto> CategorySales,
    List<ProductDistributionDto> Distribution,
    double TotalSales,
    int TotalOrders
);