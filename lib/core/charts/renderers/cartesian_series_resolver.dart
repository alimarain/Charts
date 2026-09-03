import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/chart_config.dart';
import '../models/chart_data.dart';
import '../models/chart_series.dart';
import '../models/chart_type.dart';

class CartesianSeriesResolver {
  static List<CartesianSeries<ChartDataPoint, String>> resolve({
    required UniversalChartType type,
    required List<ChartDataPoint> dataPoints,
    required ChartConfig config,
    required int activeIndex,
    required Color primaryColor,
    required Color accentColor,
    required void Function(int index, ChartDataPoint point) onPointTapped,
    required List<ChartSeriesData> multiSeries,
  }) {
    final List<CartesianSeries<ChartDataPoint, String>> seriesList = [];

    // Secondary / baseline series
    for (final extra in multiSeries) {
      seriesList.add(
        SplineSeries<ChartDataPoint, String>(
          name: extra.name,
          dataSource: extra.dataPoints,
          xValueMapper: (p, _) => p.label,
          yValueMapper: (p, _) => p.value,
          color: extra.color ?? const Color(0xFF94A3B8),
          width: 2,
          dashArray: extra.dashArray ?? const [5, 5],
        ),
      );
    }

    void handleTap(ChartPointDetails details) {
      if (details.pointIndex != null && details.pointIndex! < dataPoints.length) {
        onPointTapped(details.pointIndex!, dataPoints[details.pointIndex!]);
      }
    }

    final dataLabelSettings = DataLabelSettings(
      isVisible: config.showDataLabels,
      textStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      builder: config.valueFormatter != null
          ? (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
              final dp = data as ChartDataPoint;
              return Text(
                config.valueFormatter!(dp.value),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              );
            }
          : null,
    );

    final title = config.title ?? 'Primary';

    switch (type) {
      case UniversalChartType.line:
        seriesList.add(
          LineSeries<ChartDataPoint, String>(
            name: title,
            dataSource: dataPoints,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.value,
            color: primaryColor,
            width: 3,
            dataLabelSettings: dataLabelSettings,
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 8,
              width: 8,
              shape: DataMarkerType.circle,
              color: activeIndex >= 0 ? accentColor : primaryColor,
            ),
            onPointTap: handleTap,
          ),
        );
        break;

      case UniversalChartType.column:
        seriesList.add(
          ColumnSeries<ChartDataPoint, String>(
            name: title,
            dataSource: dataPoints,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.value,
            color: primaryColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            dataLabelSettings: dataLabelSettings,
            pointColorMapper: (p, idx) =>
                idx == activeIndex ? accentColor : (p.color ?? primaryColor),
            onPointTap: handleTap,
          ),
        );
        break;

      case UniversalChartType.bar:
        seriesList.add(
          BarSeries<ChartDataPoint, String>(
            name: title,
            dataSource: dataPoints,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.value,
            color: primaryColor,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
            dataLabelSettings: dataLabelSettings,
            pointColorMapper: (p, idx) =>
                idx == activeIndex ? accentColor : (p.color ?? primaryColor),
            onPointTap: handleTap,
          ),
        );
        break;

      case UniversalChartType.stepLine:
        seriesList.add(
          StepLineSeries<ChartDataPoint, String>(
            name: config.title ?? 'Horizon',
            dataSource: dataPoints,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.value,
            color: primaryColor,
            width: 3.5,
            dataLabelSettings: dataLabelSettings,
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 10,
              width: 10,
              shape: DataMarkerType.diamond,
              color: activeIndex >= 0 ? accentColor : Colors.white,
              borderColor: primaryColor,
              borderWidth: 2.5,
            ),
            onPointTap: handleTap,
          ),
        );
        break;

      case UniversalChartType.area:
      default:
        seriesList.add(
          SplineAreaSeries<ChartDataPoint, String>(
            name: title,
            dataSource: dataPoints,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.value,
            borderColor: primaryColor,
            borderWidth: 2.5,
            dataLabelSettings: dataLabelSettings,
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.35),
                primaryColor.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 8,
              width: 8,
              shape: DataMarkerType.circle,
              color: activeIndex >= 0 ? accentColor : primaryColor,
              borderColor: Colors.white,
              borderWidth: 2,
            ),
            onPointTap: handleTap,
          ),
        );
        break;
    }

    return seriesList;
  }
}