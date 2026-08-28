import 'package:flutter/material.dart';
import '../../../core/charts/models/chart_config.dart';
import '../../../core/charts/models/chart_data.dart';
import '../../../core/charts/models/chart_type.dart';
import '../../../core/charts/widgets/global_chart_widget.dart';
import '../../../domain/entities/basic_chart_data.dart';

class BasicChartScreen extends StatelessWidget {
  const BasicChartScreen({super.key});

  static const routeName = 'basic_chart';
  static const routePath = '/basic-chart';

  // Sample dataset with dedicated accent colors & growth metrics
  static const List<BasicChartData> _distinctiveSalesData = [
    BasicChartData(
      month: 'Jan',
      sales: 14500,
      color: Color(0xFF00F2FE),
      growthTag: '+8%',
    ),
    BasicChartData(
      month: 'Feb',
      sales: 21200,
      color: Color(0xFF38BDF8),
      growthTag: '+16%',
    ),
    BasicChartData(
      month: 'Mar',
      sales: 18400,
      color: Color(0xFF6366F1),
      growthTag: '-3%',
    ),
    BasicChartData(
      month: 'Apr',
      sales: 27800,
      color: Color(0xFF8B5CF6),
      growthTag: '+24%',
    ),
    BasicChartData(
      month: 'May',
      sales: 23600,
      color: Color(0xFFA855F7),
      growthTag: '+11%',
    ),
    BasicChartData(
      month: 'Jun',
      sales: 31500,
      color: Color(0xFF10B981),
      growthTag: '+32%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalRunRate = _distinctiveSalesData.fold<double>(
      0.0,
      (sum, item) => sum + item.sales,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quarterly Performance',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Custom column architecture via GlobalChartWidget',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header with Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00F2FE), Color(0xFF6366F1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_graph_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Revenue Velocity',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Color mapped data points with interactive snackbars',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 12,
                              color: Color(0xFF059669),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'LIVE FEED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // GlobalChartWidget Execution
                  GlobalChartWidget<BasicChartData>(
                    data: _distinctiveSalesData,
                    mapper: (BasicChartData item) => ChartDataPoint(
                      label: item.month,
                      value: item.sales,
                      color: item.color,
                    ),
                    config: const ChartConfig(
                      chartType: UniversalChartType.column,
                      height: 280,
                      showTooltip: true,
                      showLegend: false,
                      showDataLabels: true,
                      enableSelection: true,
                      enableFullscreen: false,
                      enableExport: false,
                      enableChartTypeSwitching: false,
                      accentColor: Color(0xFFF59E0B),
                      yAxisLabelFormat: 'Rs.{value}',
                    ),
                    onPointTap: (int index, ChartDataPoint point) {
                      final item = _distinctiveSalesData[index];
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: point.color ?? const Color(0xFF00F2FE),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${point.label}: Rs. ${point.value.toStringAsFixed(0)} (Growth: ${item.growthTag})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFF0F172A),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Bottom Insight Strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.insights_rounded,
                              size: 16,
                              color: Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Quarterly Gross Run Rate:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Rs. ${(totalRunRate / 1000).toStringAsFixed(1)}K',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '+22.4% Avg Growth',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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