import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/charts/models/chart_config.dart';
import '../../../core/charts/models/chart_data.dart';
import '../../../core/charts/models/chart_type.dart';
import '../../../core/charts/widgets/global_chart_widget.dart';
import '../../../domain/entities/basic_chart_data.dart';

class BasicChartScreen extends StatefulWidget {
  const BasicChartScreen({super.key});

  static const routeName = 'basic_chart';
  static const routePath = '/basic-chart';

  @override
  State<BasicChartScreen> createState() => _BasicChartScreenState();
}

class _BasicChartScreenState extends State<BasicChartScreen> {
  // 1. Dynamic state-driven dataset
  List<BasicChartData> _currentData = [
    const BasicChartData(
      month: 'January',
      sales: 12000,
      color: Color(0xFF4F46E5),
    ),
    const BasicChartData(
      month: 'February',
      sales: 18000,
      color: Color(0xFF4F46E5),
    ),
    const BasicChartData(
      month: 'March',
      sales: 15000,
      color: Color(0xFF4F46E5),
    ),
    const BasicChartData(
      month: 'April',
      sales: 22000,
      color: Color(0xFF4F46E5),
    ),
    const BasicChartData(
      month: 'May',
      sales: 19000,
      color: Color(0xFF4F46E5),
    ),
    const BasicChartData(
      month: 'June',
      sales: 25000,
      color: Color(0xFF4F46E5),
    ),
  ];

  bool _isLoading = false;
  bool _showEmpty = false;

  void _refreshSampleData() {
    final random = Random();
    setState(() {
      _showEmpty = false;
      _currentData = [
        BasicChartData(
          month: 'January',
          sales: 10000.0 + random.nextInt(8000),
          color: const Color(0xFF4F46E5),
        ),
        BasicChartData(
          month: 'February',
          sales: 12000.0 + random.nextInt(10000),
          color: const Color(0xFF4F46E5),
        ),
        BasicChartData(
          month: 'March',
          sales: 14000.0 + random.nextInt(9000),
          color: const Color(0xFF4F46E5),
        ),
        BasicChartData(
          month: 'April',
          sales: 18000.0 + random.nextInt(12000),
          color: const Color(0xFF4F46E5),
        ),
        BasicChartData(
          month: 'May',
          sales: 16000.0 + random.nextInt(11000),
          color: const Color(0xFF4F46E5),
        ),
        BasicChartData(
          month: 'June',
          sales: 20000.0 + random.nextInt(15000),
          color: const Color(0xFF4F46E5),
        ),
      ];
    });
  }

  void _toggleLoading() {
    setState(() => _isLoading = !_isLoading);
  }

  void _toggleEmpty() {
    setState(() => _showEmpty = !_showEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Chart Example',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Configurable global chart integration',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4F46E5)),
            tooltip: 'Refresh Data',
            onPressed: _refreshSampleData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Controls Bar
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _refreshSampleData,
                  icon: const Icon(Icons.autorenew_rounded, size: 16),
                  label: const Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _toggleLoading,
                  icon: const Icon(Icons.hourglass_empty_rounded, size: 16),
                  label: Text(_isLoading ? 'Stop Loading' : 'Test Loading'),
                ),
                OutlinedButton.icon(
                  onPressed: _toggleEmpty,
                  icon: const Icon(Icons.block_rounded, size: 16),
                  label: Text(_showEmpty ? 'Show Data' : 'Test Empty State'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Standard GlobalChartWidget consumption
            GlobalChartWidget<BasicChartData>(
              data: _showEmpty ? const [] : _currentData,
              isLoading: _isLoading,
              emptyMessage: 'No monthly sales records found.',
              mapper: (BasicChartData item) => ChartDataPoint(
                label: item.month,
                value: item.sales,
                color: item.color,
              ),
              config: ChartConfig(
                chartType: UniversalChartType.column,
                title: 'Monthly Sales',
                subtitle: 'Tap any bar to inspect selection and values',
                showTooltip: true,
                showLegend: false,
                showDataLabels: true,
                enableSelection: true,
                enableFullscreen: false,
                enableExport: true,
                enableChartTypeSwitching: true,
                supportedChartTypes: const [
                  UniversalChartType.column,
                  UniversalChartType.bar,
                  UniversalChartType.line,
                  UniversalChartType.area,
                ],
                xAxisTitle: 'Month',
                yAxisTitle: 'Sales (PKR)',
                valueFormatter: (double value) =>
                    'Rs. ${value.toStringAsFixed(0)}',
                primaryColor: const Color(0xFF4F46E5),
                accentColor: const Color(0xFFF59E0B),
              ),
              onPointTap: (int index, ChartDataPoint point) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${point.label}\nSales: Rs. ${point.value.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }
}