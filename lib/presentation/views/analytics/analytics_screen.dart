import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/presentation/widgets/charts/resource_pyramid_chart.dart';

import '../../../../core/services/analytics_export_service.dart';
import '../../controllers/analytics_provider.dart';
import '../../controllers/auth_provider.dart';
import '../../controllers/chart_filter_provider.dart';
import '../../widgets/charts/category_sales_chart.dart';
import '../../widgets/charts/chart_filter_bar.dart';
import '../../widgets/charts/chart_kpi_cards.dart';
import '../../widgets/charts/product_distribution_chart.dart';
import '../../widgets/charts/quarterly_performance_chart.dart';
import '../../widgets/charts/sales_overview_chart.dart';
import '../../widgets/navigation/app_header.dart';
import '../../widgets/navigation/app_sidebar.dart';
import 'widgets/analytics_title_strip.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  static const routeName = 'charts';
  static const routePath = '/charts';

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      scaffold.showSnackBar(SnackBar(content: Text('Export error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final analyticsState = ref.watch(analyticsProvider);
    final filteredResult = ref.watch(filteredAnalyticsProvider);
    final userRole = authState.user?.role == 'maker' ? 'Maker' : 'User';
    final hasToken = authState.token != null && authState.token!.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8F9FC),
          drawer: isDesktop
              ? null
              : Drawer(
                  child: AppSidebar(
                    currentRoute: '/charts',
                    hasToken: hasToken,
                    userRole: userRole,
                    isMobileDrawer: true,
                  ),
                ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Single Persistent Sidebar on Desktop
              if (isDesktop)
                AppSidebar(
                  currentRoute: '/charts',
                  hasToken: hasToken,
                  userRole: userRole,
                ),

              // Main Canvas
              Expanded(
                child: Column(
                  children: [
                    // Single Common Universal AppHeader across all pages
                    AppHeader(
                      showMenuButton: !isDesktop,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                      actions: [
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.ios_share_rounded,
                            size: 18,
                            color: Color(0xFF6B7280),
                          ),
                          tooltip: 'Export Reports',
                          onSelected: (val) =>
                              _handleGlobalExport(val, context),
                          itemBuilder: (ctx) => const [
                            PopupMenuItem(
                              value: 'pdf',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Export PDF Report',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'csv',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.table_chart_outlined,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Export Clean CSV',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Main Analytics Content
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (analyticsState.isLoading &&
                              analyticsState.data == null) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1B1638),
                                strokeWidth: 2.5,
                              ),
                            );
                          }

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
                                      onPressed: () =>
                                          ref.refresh(analyticsProvider),
                                      child: const Text('Retry Connection'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (filteredResult == null ||
                              !filteredResult.hasData) {
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
                                  const Text(
                                    'No telemetry available for selected scope.',
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => ref
                                        .read(chartFilterProvider.notifier)
                                        .reset(),
                                    child: const Text('Reset Filters'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            key: const PageStorageKey(
                              'charts_analytics_scroll_key',
                            ),
                            controller: _scrollController,
                            padding: EdgeInsets.fromLTRB(
                              isDesktop ? 28 : 16,
                              24,
                              isDesktop ? 28 : 16,
                              32,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1240),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    // 1. Performance Analytics Title
                                    const AnalyticsTitleStrip(),

                                    // 2. Advanced Analytics Controls
                                    ChartFilterBar(
                                      availableCategories:
                                          filteredResult.categories,
                                    ),
                                    const SizedBox(height: 16),

                                    // 3. KPI Metric Cards
                                    ChartKpiGrid(kpis: filteredResult.kpis),
                                    const SizedBox(height: 20),

                                    // 4. Sales Overview & Product Distribution Charts
                                    LayoutBuilder(
                                      builder: (context, boxConstraints) {
                                        final isWide =
                                            boxConstraints.maxWidth > 920;

                                        final revenueChart =
                                            SalesOverviewChart(
                                          data: filteredResult.currentSales,
                                          previousData:
                                              filteredResult.previousSales,
                                          enableNavigation: true,
                                        );

                                        final distributionChart =
                                            ProductDistributionChart(
                                          data: filteredResult.distribution,
                                          enableNavigation: true,
                                        );

                                        if (isWide) {
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 7,
                                                child: revenueChart,
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                flex: 5,
                                                child: distributionChart,
                                              ),
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

                                    // 5. Category Breakdown Column Chart
                                    CategorySalesChart(
                                      data: filteredResult.categorySales,
                                      enableNavigation: true,
                                    ),
                                    const SizedBox(height: 20),

                                    // 6. Triangular Resource Pyramid Chart (Dynamic)
                                    if (filteredResult.pyramidMetrics.isNotEmpty) ...[
                                      ResourcePyramidChart(
                                        data: filteredResult.pyramidMetrics,
                                        title: 'Category Volume Hierarchy',
                                        subtitle:
                                            'Dynamic category hierarchy based on active filter scope.',
                                      ),
                                      const SizedBox(height: 20),
                                    ],

                                    // 7. Quarterly Horizon Stepped Chart
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
      },
    );
  }
}