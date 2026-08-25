import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/chart_filter_provider.dart';
import '../../widgets/charts/category_sales_chart.dart';
import '../../widgets/charts/product_distribution_chart.dart';
import '../../widgets/charts/sales_overview_chart.dart';

class FullscreenChartScreen extends ConsumerWidget {
  const FullscreenChartScreen({
    required this.chartId,
    super.key,
  });

  static const routeName = 'fullscreen_chart';
  static const routeSubPath = 'fullscreen/:chartId';
  static const routePath = '/charts/fullscreen/:chartId';

  final String chartId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredResult = ref.watch(filteredAnalyticsProvider);
    final filter = ref.watch(chartFilterProvider);

    if (filteredResult == null || !filteredResult.hasData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chart View')),
        body: const Center(child: Text('No telemetry available for this view.')),
      );
    }

    String title;
    Widget chartWidget;

    switch (chartId) {
      case 'category_sales_chart':
        title = 'Category Breakdown (Full Screen)';
        chartWidget = CategorySalesChart(
          data: filteredResult.categorySales,
          isFullscreenMode: true,
        );
        break;
      case 'product_distribution_chart':
        title = 'Inventory Allocation (Full Screen)';
        chartWidget = ProductDistributionChart(
          data: filteredResult.distribution,
          isFullscreenMode: true,
        );
        break;
      case 'sales_overview_chart':
      default:
        title = 'Revenue Velocity (Full Screen)';
        chartWidget = SalesOverviewChart(
          data: filteredResult.currentSales,
          previousData: filteredResult.previousSales,
          isFullscreenMode: true,
        );
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              '${filter.datePreset.name} · Category: ${filter.selectedCategory}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_fullscreen_rounded),
            tooltip: 'Exit Full Screen',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: chartWidget,
      ),
    );
  }
}