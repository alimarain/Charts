import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_theme.dart';
import '../../../core/services/analytics_export_service.dart';
import '../../controllers/analytics_provider.dart';
import '../../controllers/chart_filter_provider.dart';
import '../../widgets/charts/category_sales_chart.dart';
import '../../widgets/charts/chart_filter_bar.dart';
import '../../widgets/charts/chart_kpi_cards.dart';
import '../../widgets/charts/product_distribution_chart.dart';
import '../../widgets/charts/sales_overview_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  static const routeName = 'charts';
  static const routePath = '/charts';

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleGlobalExport(String type, BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final filteredResult = ref.read(filteredAnalyticsProvider);
    final filter = ref.read(chartFilterProvider);

    if (filteredResult == null || !filteredResult.hasData) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('No data available to export.')),
      );
      return;
    }

    try {
      if (type == 'pdf') {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Generating executive PDF report...')),
        );
        await AnalyticsExportService.exportAndSharePdf(
          result: filteredResult,
          filter: filter,
        );
      } else if (type == 'csv') {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Exporting analytics CSV data...')),
        );
        await AnalyticsExportService.exportAndShareCsv(
          result: filteredResult,
          filter: filter,
        );
      }
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Export error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);
    final filteredResult = ref.watch(filteredAnalyticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Charts & Telemetry',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Interactive multi-period telemetry & category comparisons',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share_rounded, color: AppTheme.primaryColor),
            tooltip: 'Share & Export Reports',
            onSelected: (val) => _handleGlobalExport(val, context),
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Export PDF Executive Report'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart_outlined, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text('Export Clean CSV Data'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (analyticsState.isLoading && analyticsState.data == null) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Connecting to telemetry stream...',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            );
          }

          if (analyticsState.errorMessage != null && analyticsState.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: Color(0xFFDC2626),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load telemetry: ${analyticsState.errorMessage}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(analyticsProvider),
                      child: const Text('Retry Connection'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (filteredResult == null || !filteredResult.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_alt_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  const Text('No data available for the selected filters.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.read(chartFilterProvider.notifier).reset(),
                    child: const Text('Reset Filters'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            key: const PageStorageKey('charts_analytics_scroll_key'),
            controller: _scrollController,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChartFilterBar(availableCategories: filteredResult.categories),
                const SizedBox(height: 16),
                ChartKpiGrid(kpis: filteredResult.kpis),
                const SizedBox(height: 20),
                SalesOverviewChart(
                  data: filteredResult.currentSales,
                  previousData: filteredResult.previousSales,
                  enableNavigation: true,
                ),
                const SizedBox(height: 20),
                CategorySalesChart(
                  data: filteredResult.categorySales,
                  enableNavigation: true,
                ),
                const SizedBox(height: 20),
                ProductDistributionChart(
                  data: filteredResult.distribution,
                  enableNavigation: true,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}