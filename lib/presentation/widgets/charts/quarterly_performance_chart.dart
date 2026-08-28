import 'package:flutter/material.dart';
import '../../../core/charts/models/chart_config.dart';
import '../../../core/charts/models/chart_data.dart';
import '../../../core/charts/models/chart_type.dart';
import '../../../core/charts/widgets/global_chart_widget.dart';
import '../../../domain/entities/basic_chart_data.dart';

class QuarterlyPerformanceChart extends StatelessWidget {
  const QuarterlyPerformanceChart({super.key});

  static const List<BasicChartData> _milestoneData = [
    BasicChartData(
      month: 'Sprint 1',
      sales: 15000,
      color: Color(0xFF00F2FE),
      growthTag: 'Baseline',
    ),
    BasicChartData(
      month: 'Sprint 2',
      sales: 22000,
      color: Color(0xFF38BDF8),
      growthTag: '+46%',
    ),
    BasicChartData(
      month: 'Sprint 3',
      sales: 22000,
      color: Color(0xFF6366F1),
      growthTag: 'Sustained',
    ),
    BasicChartData(
      month: 'Sprint 4',
      sales: 34000,
      color: Color(0xFF8B5CF6),
      growthTag: '+54%',
    ),
    BasicChartData(
      month: 'Sprint 5',
      sales: 34000,
      color: Color(0xFFA855F7),
      growthTag: 'Sustained',
    ),
    BasicChartData(
      month: 'Sprint 6',
      sales: 48000,
      color: Color(0xFF10B981),
      growthTag: '+41%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0819),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF221A3D)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F2FE).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overflow-safe Header Track
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF16112E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2D2254)),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: Color(0xFF00F2FE),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Velocity Milestone Horizon',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Stepped horizontal thresholds across sprints',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8E88AB),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00F2FE).withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'STEPPED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF00F2FE),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Horizontal Stepped Line Chart
          GlobalChartWidget<BasicChartData>(
            data: _milestoneData,
            mapper: (BasicChartData item) => ChartDataPoint(
              label: item.month,
              value: item.sales,
            ),
            config: const ChartConfig(
              chartType: UniversalChartType.stepLine,
              height: 230,
              showTooltip: true,
              showLegend: false,
              showDataLabels: true,
              enableSelection: true,
              enableFullscreen: false,
              enableExport: false,
              enableChartTypeSwitching: false,
              primaryColor: Color(0xFF00F2FE),
              accentColor: Color(0xFFC4F74B),
              yAxisLabelFormat: 'Rs.{value}',
            ),
            onPointTap: (int index, ChartDataPoint point) {
              final item = _milestoneData[index];
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${point.label} Plateau → Rs. ${point.value.toStringAsFixed(0)} (${item.growthTag})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF1E1738),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Horizontal Scrollable Milestone Badges
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _milestoneData.map((item) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF140F29),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF261D47)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.month}: ',
                        style: const TextStyle(
                          color: Color(0xFF8E88AB),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Rs. ${(item.sales / 1000).toStringAsFixed(0)}K',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}