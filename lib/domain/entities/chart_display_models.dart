enum RevenueChartType {
  splineArea,
  line,
  column,
}

enum CategoryChartType {
  column,
  bar,
}

enum DistributionChartType {
  doughnut,
  pie,
}

class ChartDisplayState {
  const ChartDisplayState({
    this.revenueChartType = RevenueChartType.splineArea,
    this.categoryChartType = CategoryChartType.column,
    this.distributionChartType = DistributionChartType.doughnut,
    this.isExporting = false,
  });

  final RevenueChartType revenueChartType;
  final CategoryChartType categoryChartType;
  final DistributionChartType distributionChartType;
  final bool isExporting;

  ChartDisplayState copyWith({
    RevenueChartType? revenueChartType,
    CategoryChartType? categoryChartType,
    DistributionChartType? distributionChartType,
    bool? isExporting,
  }) {
    return ChartDisplayState(
      revenueChartType: revenueChartType ?? this.revenueChartType,
      categoryChartType: categoryChartType ?? this.categoryChartType,
      distributionChartType:
          distributionChartType ?? this.distributionChartType,
      isExporting: isExporting ?? this.isExporting,
    );
  }
}