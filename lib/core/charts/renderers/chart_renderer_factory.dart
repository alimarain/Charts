import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_config.dart';
import '../models/chart_data.dart';
import '../models/chart_series.dart';
import '../models/chart_type.dart';

/// Internal factory building Syncfusion series from normalized chart data.
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
      case UniversalChartType.stepLine:
      case UniversalChartType.column:
      case UniversalChartType.bar:
      case UniversalChartType.area:
        return _buildCartesianChart(
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
        return _buildCircularChart(
          type: type,
          dataPoints: dataPoints,
          config: config,
          activeIndex: activeIndex,
          onPointTapped: onPointTapped,
          isFullscreen: isFullscreen,
        );
    }
  }

  static Widget _buildCartesianChart({
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
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 0.5, color: Color(0xFFE2E8F0)),
        labelStyle: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorGridLines: const MajorGridLines(
          dashArray: [4, 4],
          color: Color(0xFFE2E8F0),
          width: 0.8,
        ),
        labelFormat: config.yAxisLabelFormat,
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
              header: '',
              canShowMarker: true,
              format: 'point.x : Rs.point.y',
              color: const Color(0xFF0F172A),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      series: _resolveCartesianSeries(
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

  static List<CartesianSeries<ChartDataPoint, String>> _resolveCartesianSeries({
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

    // Comparison or multi-series
    for (final extraSeries in multiSeries) {
      seriesList.add(
        SplineSeries<ChartDataPoint, String>(
          name: extraSeries.name,
          dataSource: extraSeries.dataPoints,
          xValueMapper: (ChartDataPoint p, _) => p.label,
          yValueMapper: (ChartDataPoint p, _) => p.value,
          color: extraSeries.color ?? const Color(0xFF94A3B8),
          width: 2,
          dashArray: extraSeries.dashArray ?? const [5, 5],
        ),
      );
    }

    void handleTap(ChartPointDetails details) {
      if (details.pointIndex != null && details.pointIndex! < dataPoints.length) {
        onPointTapped(details.pointIndex!, dataPoints[details.pointIndex!]);
      }
    }

    switch (type) {
      case UniversalChartType.line:
        seriesList.add(
          LineSeries<ChartDataPoint, String>(
            name: config.title ?? 'Primary',
            dataSource: dataPoints,
            xValueMapper: (ChartDataPoint p, _) => p.label,
            yValueMapper: (ChartDataPoint p, _) => p.value,
            color: primaryColor,
            width: 3,
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
      case UniversalChartType.stepLine:
        seriesList.add(
          StepLineSeries<ChartDataPoint, String>(
            name: config.title ?? 'Horizon',
            dataSource: dataPoints,
            xValueMapper: (ChartDataPoint p, _) => p.label,
            yValueMapper: (ChartDataPoint p, _) => p.value,
            color: primaryColor,
            width: 3.5,
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 12,
              width: 12,
              shape: DataMarkerType.diamond,
              color: activeIndex >= 0 ? accentColor : Colors.white,
              borderColor: primaryColor,
              borderWidth: 3,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: config.showDataLabels,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            onPointTap: handleTap,
          ),
        );
        break;
      case UniversalChartType.column:
        seriesList.add(
          ColumnSeries<ChartDataPoint, String>(
            name: config.title ?? 'Primary',
            dataSource: dataPoints,
            xValueMapper: (ChartDataPoint p, _) => p.label,
            yValueMapper: (ChartDataPoint p, _) => p.value,
            color: primaryColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            pointColorMapper: (ChartDataPoint p, int idx) =>
                idx == activeIndex ? accentColor : (p.color ?? primaryColor),
            onPointTap: handleTap,
          ),
        );
        break;
      case UniversalChartType.bar:
        seriesList.add(
          BarSeries<ChartDataPoint, String>(
            name: config.title ?? 'Primary',
            dataSource: dataPoints,
            xValueMapper: (ChartDataPoint p, _) => p.label,
            yValueMapper: (ChartDataPoint p, _) => p.value,
            color: primaryColor,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
            pointColorMapper: (ChartDataPoint p, int idx) =>
                idx == activeIndex ? accentColor : (p.color ?? primaryColor),
            onPointTap: handleTap,
          ),
        );
        break;
      case UniversalChartType.area:
      default:
        seriesList.add(
          SplineAreaSeries<ChartDataPoint, String>(
            name: config.title ?? 'Primary',
            dataSource: dataPoints,
            xValueMapper: (ChartDataPoint p, _) => p.label,
            yValueMapper: (ChartDataPoint p, _) => p.value,
            borderColor: primaryColor,
            borderWidth: 2.5,
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

  static Widget _buildCircularChart({
    required UniversalChartType type,
    required List<ChartDataPoint> dataPoints,
    required ChartConfig config,
    required int activeIndex,
    required void Function(int index, ChartDataPoint point) onPointTapped,
    required bool isFullscreen,
  }) {
    final isPie = type == UniversalChartType.pie;
    final totalUnits = dataPoints.fold<double>(0.0, (s, e) => s + e.value);

    return SfCircularChart(
      margin: EdgeInsets.zero,
      palette: config.palette,
      legend: Legend(
        isVisible: config.showLegend,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
      tooltipBehavior: config.showTooltip
          ? TooltipBehavior(
              enable: true,
              format: 'point.x: point.y units',
              color: const Color(0xFF0F172A),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      annotations: isPie
          ? const []
          : <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${totalUnits.toInt()}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Text(
                      'Total Units',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
      series: <CircularSeries<ChartDataPoint, String>>[
        isPie
            ? PieSeries<ChartDataPoint, String>(
                dataSource: dataPoints,
                xValueMapper: (ChartDataPoint p, _) => p.label,
                yValueMapper: (ChartDataPoint p, _) => p.value,
                dataLabelMapper: (ChartDataPoint p, _) => '${p.value.toInt()}',
                dataLabelSettings: DataLabelSettings(
                  isVisible: config.showDataLabels,
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                explode: true,
                explodeIndex: activeIndex >= 0 ? activeIndex : 0,
                onPointTap: (details) {
                  if (details.pointIndex != null &&
                      details.pointIndex! < dataPoints.length) {
                    onPointTapped(
                      details.pointIndex!,
                      dataPoints[details.pointIndex!],
                    );
                  }
                },
              )
            : DoughnutSeries<ChartDataPoint, String>(
                dataSource: dataPoints,
                xValueMapper: (ChartDataPoint p, _) => p.label,
                yValueMapper: (ChartDataPoint p, _) => p.value,
                dataLabelMapper: (ChartDataPoint p, _) => '${p.value.toInt()}',
                dataLabelSettings: DataLabelSettings(
                  isVisible: config.showDataLabels,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                innerRadius: '68%',
                radius: '85%',
                strokeColor: Colors.white,
                strokeWidth: 2,
                explode: true,
                explodeIndex: activeIndex >= 0 ? activeIndex : 0,
                onPointTap: (details) {
                  if (details.pointIndex != null &&
                      details.pointIndex! < dataPoints.length) {
                    onPointTapped(
                      details.pointIndex!,
                      dataPoints[details.pointIndex!],
                    );
                  }
                },
              ),
      ],
    );
  }
}