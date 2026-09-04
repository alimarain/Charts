import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../models/chart_config.dart';
import '../models/chart_data.dart';
import '../models/chart_type.dart';

class SparkChartRenderer {
  static Widget build({
    required UniversalChartType type,
    required List<ChartDataPoint> dataPoints,
    required ChartConfig config,
    required void Function(int index, ChartDataPoint point) onPointTapped,
  }) {
    final primaryColor = config.primaryColor ?? const Color(0xFF059669);
    final negativeColor = config.accentColor ?? const Color(0xFFEF4444);

    return Column(
      children: [
        Expanded(
          child: SfSparkWinLossChart.custom(
            dataCount: dataPoints.length,
            xValueMapper: (int index) => dataPoints[index].label,
            yValueMapper: (int index) => dataPoints[index].value,
            color: primaryColor,
            negativePointColor: negativeColor,
            firstPointColor: const Color(0xFF4F46E5),
            lastPointColor: const Color(0xFF0EA5E9),
            trackball: SparkChartTrackball(
              activationMode: SparkChartActivationMode.tap,
              borderColor: const Color(0xFFE2E8F0),
              borderWidth: 1,
              backgroundColor: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(6),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              tooltipFormatter: (TooltipFormatterDetails details) {
                final double val = (details.y ?? 0).toDouble();
                final sign = val < 0 ? '-' : '';
                return '${details.x} : ${sign}Rs. ${(val.abs() / 1000).toStringAsFixed(0)}K';
              },
            ),
          ),
        ),
        if (config.showXAxis) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dataPoints.map((dp) {
              final isProfit = dp.value >= 0;
              return Expanded(
                child: Text(
                  dp.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isProfit
                        ? const Color(0xFF64748B)
                        : const Color(0xFFEF4444),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}