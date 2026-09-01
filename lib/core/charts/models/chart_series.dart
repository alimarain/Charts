import 'dart:ui';

import 'chart_data.dart';

/// Represents a distinct dataset layer within Cartesian charts.
class ChartSeriesData {
  const ChartSeriesData({
    required this.name,
    required this.dataPoints,
    this.color,
    this.isSecondary = false,
    this.dashArray,
  });

  /// The legend label for this series.
  final String name;

  /// Standardized list of data points.
  final List<ChartDataPoint> dataPoints;

  /// Primary color for this series.
  final Color? color;

  /// Indicates if this series represents comparison/baseline data.
  final bool isSecondary;

  /// Stroke dash array for dotted or dashed lines (e.g. `[5, 5]`).
  final List<double>? dashArray;
}
