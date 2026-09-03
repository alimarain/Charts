import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/presentation/widgets/analytics/analytics_dual_chart_row.dart';
import 'package:new_app/presentation/widgets/analytics/analytics_export_menu.dart';
import 'package:new_app/presentation/widgets/charts/resource_pyramid_chart.dart';

import '../../../../core/services/analytics_export_service.dart';
import '../../controllers/analytics_provider.dart';
import '../../controllers/auth_provider.dart';
import '../../controllers/chart_filter_provider.dart';
import '../../widgets/charts/category_sales_chart.dart';
import '../../widgets/charts/chart_filter_bar.dart';
import '../../widgets/charts/chart_kpi_cards.dart';
import '../../widgets/charts/quarterly_performance_chart.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/navigation/app_header.dart';
import '../../widgets/navigation/app_sidebar.dart';
import '../../widgets/analytics/analytics_title_strip.dart';

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

  Future<void> _handleGlobalExport(String type) async {
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
              if (isDesktop)
                AppSidebar(
                  currentRoute: '/charts',
                  hasToken: hasToken,
                  userRole: userRole,
                ),
              Expanded(
                child: Column(
                  children: [
                    AppHeader(
                      showMenuButton: !isDesktop,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                      actions: [
                        AnalyticsExportMenu(
                          onExportSelected: _handleGlobalExport,
                        ),
                      ],
                    ),
                    Expanded(
                      child: _buildBody(
                        analyticsState,
                        filteredResult,
                        isDesktop,
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

  Widget _buildBody(
    AnalyticsState analyticsState,
    FilteredAnalyticsResult? filteredResult,
    bool isDesktop,
  ) {
    if (analyticsState.isLoading && analyticsState.data == null) {
      return const AppLoadingView();
    }

    if (analyticsState.errorMessage != null && analyticsState.data == null) {
      return AppErrorView(
        message: 'Could not load telemetry: ${analyticsState.errorMessage}',
        onRetry: () => ref.refresh(analyticsProvider),
      );
    }

    if (filteredResult == null || !filteredResult.hasData) {
      return AppEmptyScopeView(
        onReset: () => ref.read(chartFilterProvider.notifier).reset(),
      );
    }

    return SingleChildScrollView(
      key: const PageStorageKey('charts_analytics_scroll_key'),
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 28 : 16,
        24,
        isDesktop ? 28 : 16,
        32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const AnalyticsTitleStrip(),
              ChartFilterBar(availableCategories: filteredResult.categories),
              const SizedBox(height: 16),
              ChartKpiGrid(kpis: filteredResult.kpis),
              const SizedBox(height: 20),
              AnalyticsDualChartRow(
                currentSales: filteredResult.currentSales,
                previousSales: filteredResult.previousSales,
                distribution: filteredResult.distribution,
              ),
              const SizedBox(height: 20),
              CategorySalesChart(
                data: filteredResult.categorySales,
                enableNavigation: true,
              ),
              const SizedBox(height: 20),
              if (filteredResult.pyramidMetrics.isNotEmpty) ...[
                ResourcePyramidChart(
                  data: filteredResult.pyramidMetrics,
                  title: 'Category Volume Hierarchy',
                  subtitle: 'Dynamic category hierarchy based on active filter scope.',
                ),
                const SizedBox(height: 20),
              ],
              const QuarterlyPerformanceChart(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
