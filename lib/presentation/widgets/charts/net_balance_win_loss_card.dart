import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../core/charts/models/chart_data.dart';

class NetBalanceWinLossCard extends StatefulWidget {
  const NetBalanceWinLossCard({
    super.key,
    required this.dataPoints,
  });

  final List<ChartDataPoint> dataPoints;

  @override
  State<NetBalanceWinLossCard> createState() => _NetBalanceWinLossCardState();
}

class _NetBalanceWinLossCardState extends State<NetBalanceWinLossCard> {
  int _selectedMonthIndex = -1;
  late ZoomPanBehavior _zoomPanBehavior;

  // Solid dark tones (active & default unselected)
  static const Color activeTeal = Color(0xFF009688);
  static const Color activeCrimson = Color(0xFFD81B60);

  // Softened pastel tones (used ONLY when another bar is actively selected)
  static const Color softMint = Color(0xFFA8DAD6);
  static const Color softPink = Color(0xFFF4B8C5);

  @override
  void initState() {
    super.initState();
    _initZoomPanBehavior();
  }

  void _initZoomPanBehavior() {
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: false,
      zoomMode: ZoomMode.x,
    );
  }

  String _formatCurrency(double amount) {
    return 'Rs. ${amount.abs().toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String _formatCompact(double amount) {
    return 'RS. ${(amount.abs() / 1000).toStringAsFixed(0)}K';
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.dataPoints;

    double aggregateInflow = 0;
    double aggregateOutflow = 0;

    for (final dp in points) {
      aggregateInflow += dp.value;
      aggregateOutflow += (dp.secondaryValue ?? 0).abs();
    }

    final double activeNet;
    final String activeInflowText;
    final String activeOutflowText;
    final String contextSubtitle;

    if (_selectedMonthIndex >= 0 && _selectedMonthIndex < points.length) {
      final selectedPoint = points[_selectedMonthIndex];
      final monthInflow = selectedPoint.value;
      final monthOutflow = (selectedPoint.secondaryValue ?? 0).abs();

      activeNet = monthInflow - monthOutflow;
      contextSubtitle = 'Month: ${selectedPoint.label}';
      activeInflowText = _formatCompact(monthInflow);
      activeOutflowText = _formatCompact(monthOutflow);
    } else {
      activeNet = aggregateInflow - aggregateOutflow;
      contextSubtitle = 'Net Balance';
      activeInflowText = _formatCompact(aggregateInflow);
      activeOutflowText = _formatCompact(aggregateOutflow);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contextSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${activeNet < 0 ? "-" : ""}${_formatCurrency(activeNet)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
                if (_selectedMonthIndex >= 0)
                  TextButton.icon(
                    onPressed: () {
                      if (mounted) {
                        setState(() => _selectedMonthIndex = -1);
                      }
                    },
                    icon: const Icon(Icons.close_rounded, size: 14),
                    label: const Text('Reset', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _DeltaBadge(
                  label: activeInflowText,
                  icon: Icons.north_east_rounded,
                  color: activeTeal,
                  backgroundColor: const Color(0xFFE0F2F1),
                ),
                const SizedBox(width: 10),
                _DeltaBadge(
                  label: activeOutflowText,
                  icon: Icons.south_west_rounded,
                  color: activeCrimson,
                  backgroundColor: const Color(0xFFFCE4EC),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                key: const ValueKey('net_balance_sf_chart'),
                plotAreaBorderWidth: 0,
                margin: EdgeInsets.zero,
                zoomPanBehavior: _zoomPanBehavior,
                tooltipBehavior: TooltipBehavior(enable: false),
                enableSideBySideSeriesPlacement: true,
                primaryXAxis: CategoryAxis(
                  isVisible: true,
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0.8, color: Color(0xFFF1F5F9)),
                  autoScrollingDelta: 6,
                  autoScrollingMode: AutoScrollingMode.start,
                  labelStyle: const TextStyle(
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
                  axisLabelFormatter: (AxisLabelRenderDetails details) {
                    final double val = details.value.toDouble();
                    final sign = val < 0 ? '-' : '';
                    final absVal = val.abs();

                    final formatted = absVal >= 1000000
                        ? '${(absVal / 1000000).toStringAsFixed(1)}M'
                        : '${(absVal / 1000).toStringAsFixed(0)}K';

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
                  ColumnSeries<ChartDataPoint, String>(
                    name: 'Cash In',
                    dataSource: points,
                    animationDuration: 0, // Prevents scheduler callback leaks during rebuilds
                    xValueMapper: (ChartDataPoint p, _) => p.label,
                    yValueMapper: (ChartDataPoint p, _) => p.value,
                    width: 0.72,
                    spacing: 0.05,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                    pointColorMapper: (ChartDataPoint p, int index) {
                      if (_selectedMonthIndex == -1) return activeTeal;
                      return index == _selectedMonthIndex ? activeTeal : softMint;
                    },
                    onPointTap: (ChartPointDetails details) {
                      HapticFeedback.lightImpact();
                      if (details.pointIndex != null && mounted) {
                        setState(() {
                          _selectedMonthIndex =
                              _selectedMonthIndex == details.pointIndex
                                  ? -1
                                  : details.pointIndex!;
                        });
                      }
                    },
                  ),
                  ColumnSeries<ChartDataPoint, String>(
                    name: 'Cash Out',
                    dataSource: points,
                    animationDuration: 0, // Prevents scheduler callback leaks during rebuilds
                    xValueMapper: (ChartDataPoint p, _) => p.label,
                    yValueMapper: (ChartDataPoint p, _) =>
                        p.secondaryValue ?? 0.0,
                    width: 0.72,
                    spacing: 0.05,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5)),
                    pointColorMapper: (ChartDataPoint p, int index) {
                      if (_selectedMonthIndex == -1) return activeCrimson;
                      return index == _selectedMonthIndex ? activeCrimson : softPink;
                    },
                    onPointTap: (ChartPointDetails details) {
                      HapticFeedback.lightImpact();
                      if (details.pointIndex != null && mounted) {
                        setState(() {
                          _selectedMonthIndex =
                              _selectedMonthIndex == details.pointIndex
                                  ? -1
                                  : details.pointIndex!;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}