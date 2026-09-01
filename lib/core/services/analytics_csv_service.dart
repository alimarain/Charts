import '../../domain/entities/chart_filter_models.dart';
import '../../presentation/controllers/chart_filter_provider.dart';

class AnalyticsCsvService {
  static String _escapeCsvValue(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    if (str.contains(',') ||
        str.contains('"') ||
        str.contains('\n') ||
        str.contains('\r')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  static String generateCsv({
    required FilteredAnalyticsResult result,
    required ChartFilterState filter,
  }) {
    final List<List<dynamic>> rows = [];

    // Metadata header
    rows.add(['VIBEFLOW ANALYTICS EXPORT REPORT']);
    rows.add(['Generated At', DateTime.now().toIso8601String()]);
    rows.add(['Date Range Preset', filter.datePreset.name]);
    rows.add(['Selected Category', filter.selectedCategory]);
    rows.add(['Comparison Setting', filter.comparisonPeriod.name]);
    rows.add([]);

    // KPI Summary
    rows.add(['--- KPI SUMMARY ---']);
    rows.add(['Metric', 'Current Value', 'Growth %']);
    rows.add([
      'Revenue (PKR)',
      result.kpis.currentRevenue,
      '${result.kpis.revenueGrowthPercent.toStringAsFixed(1)}%',
    ]);
    rows.add([
      'Orders',
      result.kpis.currentOrders,
      '${result.kpis.ordersGrowthPercent.toStringAsFixed(1)}%',
    ]);
    rows.add(['Active SKUs', result.kpis.activeSkus, 'N/A']);
    rows.add([
      'Target Achievement',
      '${result.kpis.targetAchievementPercent.toStringAsFixed(1)}%',
      'N/A',
    ]);
    rows.add([]);

    // Revenue Over Time Table
    rows.add(['--- REVENUE VELOCITY ---']);
    rows.add(['Period/Day', 'Current Revenue', 'Previous Period Baseline']);
    for (int i = 0; i < result.currentSales.length; i++) {
      final current = result.currentSales[i];
      final prev = i < result.previousSales.length
          ? result.previousSales[i].value
          : 0.0;
      rows.add([current.label, current.value, prev]);
    }
    rows.add([]);

    // Category Sales Table
    rows.add(['--- CATEGORY REVENUE ---']);
    rows.add(['Department', 'Sales (PKR)']);
    for (final item in result.categorySales) {
      rows.add([item.category, item.sales]);
    }
    rows.add([]);

    // Inventory Distribution Table
    rows.add(['--- INVENTORY DISTRIBUTION ---']);
    rows.add(['Department', 'SKU Count']);
    for (final item in result.distribution) {
      rows.add([item.category, item.count]);
    }

    // Convert list of rows to standard RFC 4180 CSV string
    return rows.map((row) => row.map(_escapeCsvValue).join(',')).join('\r\n');
  }
}
