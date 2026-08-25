enum ChartType {
  salesOverview,
  categoryPerformance,
  productDistribution,
}

class SelectedChartItem {
  const SelectedChartItem({
    required this.chartId,
    required this.chartType,
    required this.dataIndex,
    required this.label,
    required this.value,
    this.unit = 'PKR',
    this.secondaryMetric,
    this.description,
  });

  final String chartId;
  final ChartType chartType;
  final int dataIndex;
  final String label;
  final num value;
  final String unit;
  final String? secondaryMetric;
  final String? description;

  String get formattedValue => unit == 'PKR'
      ? 'Rs. ${value.toStringAsFixed(0)}'
      : '$value $unit';

  SelectedChartItem copyWith({
    String? chartId,
    ChartType? chartType,
    int? dataIndex,
    String? label,
    num? value,
    String? unit,
    String? secondaryMetric,
    String? description,
  }) {
    return SelectedChartItem(
      chartId: chartId ?? this.chartId,
      chartType: chartType ?? this.chartType,
      dataIndex: dataIndex ?? this.dataIndex,
      label: label ?? this.label,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      secondaryMetric: secondaryMetric ?? this.secondaryMetric,
      description: description ?? this.description,
    );
  }
}