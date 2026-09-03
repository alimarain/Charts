import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/chart_config.dart';
import '../models/chart_data.dart';
import '../models/chart_series.dart';
import '../models/chart_type.dart';
import 'cartesian_series_resolver.dart';

class CartesianChartRenderer {
  static Widget build({
    required UniversalChartType type,
    required List<ChartDataPoint> dataPoints,
    required ChartConfig config,
    required int activeIndex,
    required void Function(int index, ChartDataPoint point) onPointTapped,
    required List<ChartSeriesData> multiSeries,
    required bool isFullscreen,
  }) {
    final isTransposed = type == UniversalChartType.bar;
    final primaryColor = config.primaryColor ?? const Color(0xFF4F46E5);
    final accentColor = config.accentColor ?? const Color(0xFFF59E0B);

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      isTransposed: isTransposed,
      legend: Legend(
        isVisible: config.showLegend || multiSeries.isNotEmpty,
        position: LegendPosition.top,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      ),
      primaryXAxis: CategoryAxis(
        isVisible: config.showXAxis,
        title: config.xAxisTitle != null
            ? AxisTitle(
                text: config.xAxisTitle,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              )
            : const AxisTitle(),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0.5, color: Color(0xFFE2E8F0)),
        labelStyle: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
      ),
      primaryYAxis: NumericAxis(
        isVisible: config.showYAxis,
        title: config.yAxisTitle != null
            ? AxisTitle(
                text: config.yAxisTitle,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              )
            : const AxisTitle(),
        axisLine: const AxisLine(width: 0),
        majorGridLines: const MajorGridLines(
          dashArray: [4, 4],
          color: Color(0xFFE2E8F0),
          width: 0.8,
        ),
        labelFormat: config.yAxisLabelFormat ??
            (config.valueFormatter != null ? null : 'Rs.{value}'),
        axisLabelFormatter: config.valueFormatter != null
            ? (AxisLabelRenderDetails details) => ChartAxisLabel(
                config.valueFormatter!(details.value.toDouble()),
                const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              )
            : null,
        labelStyle: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
        plotBands: config.targetValue != null
            ? [
                PlotBand(
                  isVisible: true,
                  start: config.targetValue! / 7,
                  end: config.targetValue! / 7,
                  borderColor: const Color(0xFFEF4444),
                  borderWidth: 2,
                  dashArray: const [6, 4],
                  text: config.targetLabel,
                  textStyle: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                  horizontalTextAlignment: TextAnchor.end,
                  verticalTextAlignment: TextAnchor.start,
                ),
              ]
            : const [],
      ),
      tooltipBehavior: config.showTooltip
          ? TooltipBehavior(
              enable: true,
              header: config.tooltipHeader ?? '',
              canShowMarker: true,
              format: config.valueFormatter != null
                  ? 'point.x : point.y'
                  : 'point.x : Rs.point.y',
              color: const Color(0xFF0F172A),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      series: CartesianSeriesResolver.resolve(
        type: type,
        dataPoints: dataPoints,
        config: config,
        activeIndex: activeIndex,
        primaryColor: primaryColor,
        accentColor: accentColor,
        onPointTapped: onPointTapped,
        multiSeries: multiSeries,
      ),
    );
  }
}