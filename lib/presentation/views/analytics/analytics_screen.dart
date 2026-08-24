import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/app/app_theme.dart';
import '../../controllers/analytics_provider.dart';
import '../../controllers/analytics_state.dart';
import '../../widgets/charts/category_sales_chart.dart';
import '../../widgets/charts/product_distribution_chart.dart';
import '../../widgets/charts/sales_overview_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  static const routeName = 'analytics';
  static const routePath = '/analytics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Analytics & Telemetry'),
      ),
      body: analyticsState.isLoading && analyticsState.data == null
          ? const Center(child: CircularProgressIndicator())
          : analyticsState.isError && analyticsState.data == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
                      const SizedBox(height: 12),
                      Text(analyticsState.errorMessage ?? 'Analytics offline'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: notifier.retry,
                        child: const Text('Retry Connection'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time Filter Switcher
                      SegmentedButton<AnalyticsPeriod>(
                        segments: const [
                          ButtonSegment(value: AnalyticsPeriod.sevenDays, label: Text('7 Days')),
                          ButtonSegment(value: AnalyticsPeriod.thirtyDays, label: Text('30 Days')),
                          ButtonSegment(value: AnalyticsPeriod.ninetyDays, label: Text('90 Days')),
                        ],
                        selected: {analyticsState.period},
                        onSelectionChanged: (set) => notifier.setPeriod(set.first),
                      ),
                      const SizedBox(height: 16),

                      // Metric Summary Cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 600;
                          return GridView.count(
                            crossAxisCount: isWide ? 4 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: isWide ? 1.6 : 1.4,
                            children: [
                              _SummaryMetricCard(
                                title: 'Total Revenue',
                                value: 'Rs. ${analyticsState.totalRevenue.toStringAsFixed(0)}',
                                icon: Icons.payments_rounded,
                                color: AppTheme.primaryColor,
                              ),
                              const _SummaryMetricCard(
                                title: 'Total Orders',
                                value: '1,428',
                                icon: Icons.shopping_bag_rounded,
                                color: AppTheme.secondaryColor,
                              ),
                              _SummaryMetricCard(
                                title: 'Active Inventory',
                                value: '${analyticsState.totalInventoryCount} SKUs',
                                icon: Icons.inventory_2_rounded,
                                color: const Color(0xFFF59E0B),
                              ),
                              const _SummaryMetricCard(
                                title: 'Avg Basket',
                                value: 'Rs. 4,850',
                                icon: Icons.receipt_long_rounded,
                                color: Color(0xFF06B6D4),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Chart Sections
                      SalesOverviewChart(data: analyticsState.data!.weeklySales),
                      const SizedBox(height: 16),
                      CategorySalesChart(data: analyticsState.data!.categorySales),
                      const SizedBox(height: 16),
                      ProductDistributionChart(data: analyticsState.data!.distribution),
                    ],
                  ),
                ),
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
                Icon(icon, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}