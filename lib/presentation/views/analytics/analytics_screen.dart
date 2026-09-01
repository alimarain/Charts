import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_provider.dart';
import '../../controllers/analytics_provider.dart';
import '../../controllers/chart_filter_provider.dart';
import '../../widgets/charts/category_sales_chart.dart';
import '../../widgets/charts/chart_filter_bar.dart';
import '../../widgets/charts/chart_kpi_cards.dart';
import '../../widgets/charts/product_distribution_chart.dart';
import '../../widgets/charts/quarterly_performance_chart.dart';
import '../../widgets/charts/sales_overview_chart.dart';
import '../../widgets/navigation/app_sidebar.dart';
import 'widgets/analytics_header_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final analyticsState = ref.watch(analyticsProvider);
    final filteredResult = ref.watch(filteredAnalyticsProvider);
    final userRole = authState.user?.role == 'maker' ? 'Maker' : 'User';
    final hasToken = authState.token != null && authState.token!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Unified System Sidebar
          AppSidebar(
            currentRoute: '/charts',
            hasToken: hasToken,
            userRole: userRole,
          ),

          // 2. Main Executive Canvas
          Expanded(
            child: Column(
              children: [
                // Top Global Bar & Date Presets
                const AnalyticsHeaderBar(),

                // Scrollable Content View
                Expanded(
                  child: Builder(
                    builder: (context) {
                      // 1. Loading State
                      if (analyticsState.isLoading && analyticsState.data == null) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1B1638),
                            strokeWidth: 2.5,
                          ),
                        );
                      }

                      // 2. Error State
                      if (analyticsState.errorMessage != null &&
                          analyticsState.data == null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cloud_off_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 40,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Could not load telemetry: ${analyticsState.errorMessage}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton(
                                  onPressed: () => ref.refresh(analyticsProvider),
                                  child: const Text('Retry Connection'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // 3. Filtered Empty State
                      if (filteredResult == null || !filteredResult.hasData) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.filter_alt_off_rounded,
                                size: 40,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(height: 10),
                              const Text('No telemetry available for selected scope.'),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () =>
                                    ref.read(chartFilterProvider.notifier).reset(),
                                child: const Text('Reset Filters'),
                              ),
                            ],
                          ),
                        );
                      }

                      // 4. Main Analytics Dashboard (All 4 Charts & Controls)
                      return SingleChildScrollView(
                        key: const PageStorageKey('charts_analytics_scroll_key'),
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1240),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Advanced Filter Bar (Category, Target switch, Range)
                                ChartFilterBar(availableCategories: filteredResult.categories),
                                const SizedBox(height: 16),

                                // KPI Metric Cards
                                ChartKpiGrid(kpis: filteredResult.kpis),
                                const SizedBox(height: 20),

                                // Responsive Grid for Chart 1 & Chart 3
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isDesktop = constraints.maxWidth > 920;

                                    final revenueChart = SalesOverviewChart(
                                      data: filteredResult.currentSales,
                                      previousData: filteredResult.previousSales,
                                      enableNavigation: true,
                                    );

                                    final distributionChart = ProductDistributionChart(
                                      data: filteredResult.distribution,
                                      enableNavigation: true,
                                    );

                                    if (isDesktop) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(flex: 7, child: revenueChart),
                                          const SizedBox(width: 16),
                                          Expanded(flex: 5, child: distributionChart),
                                        ],
                                      );
                                    }

                                    return Column(
                                      children: [
                                        revenueChart,
                                        const SizedBox(height: 16),
                                        distributionChart,
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Chart 2: Category Breakdown
                                CategorySalesChart(
                                  data: filteredResult.categorySales,
                                  enableNavigation: true,
                                ),
                                const SizedBox(height: 20),

                                // Chart 4: Stepped Velocity Milestone Horizon
                                const QuarterlyPerformanceChart(),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}