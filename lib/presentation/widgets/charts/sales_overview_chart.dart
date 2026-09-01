import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/widgets/charts/fullscreen_chart_screen.dart';

import '../../../app/app_theme.dart';
import '../../../core/charts/models/chart_config.dart';
import '../../../core/charts/models/chart_data.dart';
import '../../../core/charts/models/chart_type.dart';
import '../../../core/charts/widgets/global_chart_widget.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/entities/chart_display_models.dart';
import '../../../domain/entities/chart_filter_models.dart';
import '../../../domain/entities/chart_interaction.dart';
import '../../controllers/chart_display_provider.dart';
import '../../controllers/chart_filter_provider.dart';
import '../../controllers/chart_interaction_provider.dart';
import '../../views/dashboard/chart_details_screen.dart';

class SalesOverviewChart extends ConsumerWidget {
  const SalesOverviewChart({
    required this.data,
    this.previousData = const [],
    this.chartId = 'sales_overview_chart',
    this.enableNavigation = true,
    this.isFullscreenMode = false,
    super.key,
  });

  final List<SalesData> data;
  final List<SalesData> previousData;
  final String chartId;
  final bool enableNavigation;
  final bool isFullscreenMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(chartFilterProvider);
    final displayState = ref.watch(chartDisplayProvider);
    final interactionState = ref.watch(chartInteractionProvider);
    final selectedItem = interactionState.selectedItem;
    final activeIndex =
        (selectedItem != null && selectedItem.chartId == chartId)
        ? selectedItem.dataIndex
        : -1;

    UniversalChartType mapRevenueType(RevenueChartType type) {
      switch (type) {
        case RevenueChartType.line:
          return UniversalChartType.line;
        case RevenueChartType.column:
          return UniversalChartType.column;
        case RevenueChartType.splineArea:
          return UniversalChartType.area;
      }
    }

    return GlobalChartWidget<SalesData>(
      data: data,
      comparisonData: filter.comparisonPeriod != ComparisonPeriod.none
          ? previousData
          : null,
      chartId: chartId,
      activeIndex: activeIndex,
      isFullscreenMode: isFullscreenMode,
      mapper: (SalesData item) =>
          ChartDataPoint(label: item.label, value: item.value),
      config: ChartConfig(
        chartType: mapRevenueType(displayState.revenueChartType),
        title: 'Revenue Velocity & Comparisons',
        subtitle: filter.isTargetEnabled
            ? 'Target: Rs. ${(filter.targetRevenue / 1000).toStringAsFixed(0)}K · Tap point to inspect'
            : 'Tap point to inspect',
        targetValue: filter.isTargetEnabled ? filter.targetRevenue : null,
        primaryColor: AppTheme.primaryColor,
        accentColor: AppTheme.accentColor,
        supportedChartTypes: const [
          UniversalChartType.area,
          UniversalChartType.line,
          UniversalChartType.column,
        ],
      ),
      onChartTypeChanged: (type) {
        final notifier = ref.read(chartDisplayProvider.notifier);
        if (type == UniversalChartType.line) {
          notifier.setRevenueChartType(RevenueChartType.line);
        } else if (type == UniversalChartType.column) {
          notifier.setRevenueChartType(RevenueChartType.column);
        } else {
          notifier.setRevenueChartType(RevenueChartType.splineArea);
        }
      },
      onFullscreenTap: () => context.pushNamed(
        FullscreenChartScreen.routeName,
        pathParameters: {'chartId': chartId},
      ),
      onPointTap: (index, point) {
        final item = SelectedChartItem(
          chartId: chartId,
          chartType: ChartType.salesOverview,
          dataIndex: index,
          label: point.label,
          value: point.value,
          unit: 'PKR',
          secondaryMetric:
              '${filter.selectedCategory} · ${filter.datePreset.name}',
          description:
              'Gross checkout run rate for ${point.label} within the current filter scope',
        );
        ref.read(chartInteractionProvider.notifier).selectItem(item);
        if (enableNavigation) {
          context.pushNamed(ChartDetailsScreen.routeName, extra: item);
        }
      },
    );
  }
}
