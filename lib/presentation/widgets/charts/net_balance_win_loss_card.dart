import 'package:flutter/material.dart';
import 'package:new_app/presentation/widgets/analytics/cashflow_header_bar.dart';
import 'package:new_app/presentation/widgets/analytics/net_balance_chart_canvas.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../core/charts/models/chart_data.dart';

class NetBalanceWinLossCard extends StatefulWidget {
  const NetBalanceWinLossCard({
    super.key,
    required this.dataPoints,
    this.selectedIndex,
    this.onPointSelected,
  });

  final List<ChartDataPoint> dataPoints;
  final int? selectedIndex;
  final ValueChanged<int>? onPointSelected;

  @override
  State<NetBalanceWinLossCard> createState() => _NetBalanceWinLossCardState();
}

class _NetBalanceWinLossCardState extends State<NetBalanceWinLossCard> {
  int _internalIndex = -1;
  late final ZoomPanBehavior _zoomPanBehavior;

  int get _active => widget.selectedIndex ?? _internalIndex;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(enablePanning: true, enablePinching: false, zoomMode: ZoomMode.x);
  }

  void _handleTap(int index) {
    final next = _active == index ? -1 : index;
    if (widget.onPointSelected != null) {
      widget.onPointSelected!(next);
    } else if (mounted) {
      setState(() => _internalIndex = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.dataPoints;
    final active = _active;

    final double inVal = (active >= 0 && active < points.length)
        ? points[active].value
        : points.fold(0.0, (s, p) => s + p.value);

    final double outVal = (active >= 0 && active < points.length)
        ? (points[active].secondaryValue ?? 0).abs()
        : points.fold(0.0, (s, p) => s + (p.secondaryValue ?? 0).abs());

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
            NetBalanceMetricHeader(
              inflow: inVal,
              outflow: outVal,
              isFiltered: active >= 0,
              onReset: () => _handleTap(active),
            ),
            const SizedBox(height: 24),
            NetBalanceChartCanvas(
              points: points,
              activeIndex: active,
              zoomPanBehavior: _zoomPanBehavior,
              onPointTap: _handleTap,
            ),
          ],
        ),
      ),
    );
  }
}