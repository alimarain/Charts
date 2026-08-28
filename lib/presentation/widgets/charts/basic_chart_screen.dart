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

  // Sample static dataset
  static const List<BasicChartData> _sampleMonthlySales = [
    BasicChartData(month: 'January', sales: 12000),
    BasicChartData(month: 'February', sales: 18000),
    BasicChartData(month: 'March', sales: 15000),
    BasicChartData(month: 'April', sales: 22000),
    BasicChartData(month: 'May', sales: 19000),
    BasicChartData(month: 'June', sales: 25000),
  ];

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
              'Example of creating a chart using GlobalChartWidget',
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
            // Standard GlobalChartWidget consumption
            GlobalChartWidget<BasicChartData>(
              data: _sampleMonthlySales,
              mapper: (BasicChartData item) => ChartDataPoint(
                label: item.month,
                value: item.sales,
              ),
              config: const ChartConfig(
                chartType: UniversalChartType.column,
                title: 'Monthly Sales Volume',
                subtitle: 'Tap any bar to trigger an application-level callback',
                showTooltip: true,
                showLegend: false,
                enableSelection: true,
                enableFullscreen: false,
                enableExport: false,
                enableChartTypeSwitching: false,
                primaryColor: Color(0xFF4F46E5),
                yAxisLabelFormat: 'Rs.{value}',
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