/// A simple, standalone domain model representing monthly sales figures.
class BasicChartData {
  const BasicChartData({
    required this.month,
    required this.sales,
  });

  final String month;
  final double sales;
}