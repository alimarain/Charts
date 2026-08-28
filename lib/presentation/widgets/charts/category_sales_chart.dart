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
import '../../../domain/entities/chart_interaction.dart';
import '../../controllers/chart_display_provider.dart';
import '../../controllers/chart_interaction_provider.dart';
import '../../views/dashboard/chart_details_screen.dart';

class CategorySalesChart extends ConsumerWidget {
  const CategorySalesChart({
    required this.data,
    this.chartId = 'category_sales_chart',
    this.enableNavigation = true,
    this.isFullscreenMode = false,
    super.key,
  });

  final List<CategorySalesData> data;
  final String chartId;
  final bool enableNavigation;
  final bool isFullscreenMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayState = ref.watch(chartDisplayProvider);
    final interactionState = ref.watch(chartInteractionProvider);
    final selectedItem = interactionState.selectedItem;
    final activeIndex =
        (selectedItem != null && selectedItem.chartId == chartId)
            ? selectedItem.dataIndex
            : -1;

    final universalType = displayState.categoryChartType == CategoryChartType.bar
        ? UniversalChartType.bar
        : UniversalChartType.column;

    return GlobalChartWidget<CategorySalesData>(
      data: data,
      chartId: chartId,
      activeIndex: activeIndex,
      isFullscreenMode: isFullscreenMode,
      mapper: (CategorySalesData item) => ChartDataPoint(
        label: item.category,
        value: item.sales,
      ),
      config: ChartConfig(
        chartType: universalType,
        title: 'Category Breakdown',
        subtitle: 'Tap bars to view department telemetry',
        primaryColor: const Color(0xFF059669),
        accentColor: AppTheme.accentColor,
        supportedChartTypes: const [
          UniversalChartType.column,
          UniversalChartType.bar,
        ],
      ),
      onChartTypeChanged: (type) {
        ref.read(chartDisplayProvider.notifier).setCategoryChartType(
              type == UniversalChartType.bar
                  ? CategoryChartType.bar
                  : CategoryChartType.column,
            );
      },
      onFullscreenTap: () => context.pushNamed(
        FullscreenChartScreen.routeName,
        pathParameters: {'chartId': chartId},
      ),
      onPointTap: (index, point) {
        final item = SelectedChartItem(
          chartId: chartId,
          chartType: ChartType.categoryPerformance,
          dataIndex: index,
          label: point.label,
          value: point.value,
          unit: 'PKR',
          secondaryMetric: 'Active Stock Share',
          description: 'Gross department order flow for ${point.label}',
        );
        ref.read(chartInteractionProvider.notifier).selectItem(item);
        if (enableNavigation) {
          context.pushNamed(ChartDetailsScreen.routeName, extra: item);
        }
      },
    );
  }
}