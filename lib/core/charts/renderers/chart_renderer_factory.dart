import 'package:flutter/material.dart';

import '../models/chart_config.dart';
import '../models/chart_data.dart';
import '../models/chart_series.dart';
import '../models/chart_type.dart';
import 'cartesian_chart_renderer.dart';
import 'circular_chart_renderer.dart';

class ChartRendererFactory {
  static Widget buildChart({
    required UniversalChartType type,
    required List<ChartDataPoint> dataPoints,
    required ChartConfig config,
    required int activeIndex,
    required void Function(int index, ChartDataPoint point) onPointTapped,
    List<ChartSeriesData> multiSeries = const [],
    bool isFullscreen = false,
  }) {
    switch (type) {
      case UniversalChartType.line:
      case UniversalChartType.column:
      case UniversalChartType.bar:
      case UniversalChartType.area:
      case UniversalChartType.stepLine:
        return CartesianChartRenderer.build(
          type: type,
          dataPoints: dataPoints,
          config: config,
          activeIndex: activeIndex,
          onPointTapped: onPointTapped,
          multiSeries: multiSeries,
          isFullscreen: isFullscreen,
        );
      case UniversalChartType.pie:
      case UniversalChartType.doughnut:
        return CircularChartRenderer.build(
          type: type,
          dataPoints: dataPoints,
          config: config,
          activeIndex: activeIndex,
          onPointTapped: onPointTapped,
          isFullscreen: isFullscreen,
        );
    }
  }
}