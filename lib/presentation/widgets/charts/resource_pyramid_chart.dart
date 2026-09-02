import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../domain/entities/pyramid_metric.dart';

class ResourcePyramidChart extends StatefulWidget {
  const ResourcePyramidChart({
    super.key,
    required this.data,
    this.title = 'Resource Hierarchy Distribution',
    this.subtitle = 'Volume breakdown across organizational tiers.',
  });

  final List<PyramidMetric> data;
  final String title;
  final String subtitle;

  @override
  State<ResourcePyramidChart> createState() => _ResourcePyramidChartState();
}

class _ResourcePyramidChartState extends State<ResourcePyramidChart> {
  late final TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      format: 'point.x : point.y units',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),

          // Pyramid Canvas
          SizedBox(
            height: 320,
            child: SfPyramidChart(
              tooltipBehavior: _tooltipBehavior,
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: TextStyle(fontSize: 11, color: Color(0xFF374151)),
              ),
              series: PyramidSeries<PyramidMetric, String>(
                dataSource: widget.data,
                xValueMapper: (PyramidMetric item, _) => item.stage,
                yValueMapper: (PyramidMetric item, _) => item.value,
                pointColorMapper: (PyramidMetric item, _) => item.color,
                gapRatio: 0.04, // Creates sleek card-like spacing between slices
                explode: true,  // Pops out segment on user tap
                pyramidMode: PyramidMode.linear,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside,
                  textStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}