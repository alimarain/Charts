import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/chart_config.dart';
import '../models/chart_data.dart';
import '../models/chart_type.dart';

class CircularChartRenderer {
  static Widget build({
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
              format: config.valueFormatter != null
                  ? 'point.x: point.y'
                  : 'point.x: point.y units',
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
                      config.valueFormatter != null
                          ? config.valueFormatter!(totalUnits)
                          : '${totalUnits.toInt()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
      series: <CircularSeries<ChartDataPoint, String>>[
        if (isPie)
          PieSeries<ChartDataPoint, String>(
            dataSource: dataPoints,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.value,
            dataLabelMapper: (p, _) => config.valueFormatter != null
                ? config.valueFormatter!(p.value)
                : '${p.value.toInt()}',
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
              if (details.pointIndex != null && details.pointIndex! < dataPoints.length) {
                onPointTapped(details.pointIndex!, dataPoints[details.pointIndex!]);
              }
            },
          )
        else
          DoughnutSeries<ChartDataPoint, String>(
            dataSource: dataPoints,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.value,
            dataLabelMapper: (p, _) => config.valueFormatter != null
                ? config.valueFormatter!(p.value)
                : '${p.value.toInt()}',
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
              if (details.pointIndex != null && details.pointIndex! < dataPoints.length) {
                onPointTapped(details.pointIndex!, dataPoints[details.pointIndex!]);
              }
            },
          ),
      ],
    );
  }
}