import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../core/charts/models/chart_data.dart';

class NetBalanceChartCanvas extends StatelessWidget {
  const NetBalanceChartCanvas({
    super.key,
    required this.points,
    required this.activeIndex,
    required this.zoomPanBehavior,
    required this.onPointTap,
  });

  final List<ChartDataPoint> points;
  final int activeIndex;
  final ZoomPanBehavior zoomPanBehavior;
  final ValueChanged<int> onPointTap;

  static const Color activeTeal = Color(0xFF009688);
  static const Color activeCrimson = Color(0xFFD81B60);
  static const Color softMint = Color(0xFFA8DAD6);
  static const Color softPink = Color(0xFFF4B8C5);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: SfCartesianChart(
        key: const ValueKey('net_balance_sf_chart'),
        plotAreaBorderWidth: 0,
        margin: EdgeInsets.zero,
        zoomPanBehavior: zoomPanBehavior,
        tooltipBehavior: TooltipBehavior(enable: false),
        enableSideBySideSeriesPlacement: true,
        primaryXAxis: const CategoryAxis(
          isVisible: true,
          majorGridLines: MajorGridLines(width: 0),
          axisLine: AxisLine(width: 0.8, color: Color(0xFFF1F5F9)),
          autoScrollingDelta: 6,
          autoScrollingMode: AutoScrollingMode.start,
          labelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
        primaryYAxis: NumericAxis(
          isVisible: true,
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: const MajorGridLines(
            width: 0.8,
            color: Color(0xFFF3F4F6),
          ),
          axisLabelFormatter: (details) {
            final v = details.value.toDouble();
            final sign = v < 0 ? '-' : '';
            final abs = v.abs();
            final formatted = abs >= 1000000
                ? '${(abs / 1000000).toStringAsFixed(1)}M'
                : '${(abs / 1000).toStringAsFixed(0)}K';
            return ChartAxisLabel(
              '$sign$formatted',
              const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            );
          },
        ),
        series: <CartesianSeries<ChartDataPoint, String>>[
          _series(isCashIn: true),
          _series(isCashIn: false),
        ],
      ),
    );
  }

  ColumnSeries<ChartDataPoint, String> _series({required bool isCashIn}) {
    return ColumnSeries<ChartDataPoint, String>(
      name: isCashIn ? 'Cash In' : 'Cash Out',
      dataSource: points,
      animationDuration: 0,
      xValueMapper: (p, _) => p.label,
      yValueMapper: (p, _) => isCashIn ? p.value : (p.secondaryValue ?? 0.0),
      width: 0.72,
      spacing: 0.05,
      borderRadius: BorderRadius.vertical(
        top: isCashIn ? const Radius.circular(5) : Radius.zero,
        bottom: isCashIn ? Radius.zero : const Radius.circular(5),
      ),
      pointColorMapper: (p, i) {
        if (activeIndex == -1) return isCashIn ? activeTeal : activeCrimson;
        return i == activeIndex
            ? (isCashIn ? activeTeal : activeCrimson)
            : (isCashIn ? softMint : softPink);
      },
      onPointTap: (details) {
        if (details.pointIndex != null) {
          HapticFeedback.lightImpact();
          onPointTap(details.pointIndex!);
        }
      },
    );
  }
}
