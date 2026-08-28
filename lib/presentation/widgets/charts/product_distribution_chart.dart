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

class ProductDistributionChart extends ConsumerWidget {
  const ProductDistributionChart({
    required this.data,
    this.chartId = 'product_distribution_chart',
    this.enableNavigation = true,
    this.isFullscreenMode = false,
    super.key,
  });

  final List<ProductDistributionData> data;
  final String chartId;
  final bool enableNavigation;
  final bool isFullscreenMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalUnits = data.fold<int>(0, (sum, item) => sum + item.count);
    final displayState = ref.watch(chartDisplayProvider);
    final interactionState = ref.watch(chartInteractionProvider);
    final selectedItem = interactionState.selectedItem;
    final activeIndex =
        (selectedItem != null && selectedItem.chartId == chartId)
            ? selectedItem.dataIndex
            : 0;

    final universalType = displayState.distributionChartType == DistributionChartType.pie
        ? UniversalChartType.pie
        : UniversalChartType.doughnut;

    return GlobalChartWidget<ProductDistributionData>(
      data: data,
      chartId: chartId,
      activeIndex: activeIndex,
      isFullscreenMode: isFullscreenMode,
      mapper: (ProductDistributionData item) => ChartDataPoint(
        label: item.category,
        value: item.count.toDouble(),
      ),
      config: ChartConfig(
        chartType: universalType,
        title: 'Inventory Allocation',
        subtitle: 'Tap slices to inspect unit distribution',
        showLegend: true,
        showDataLabels: true,
        accentColor: AppTheme.accentColor,
        supportedChartTypes: const [
          UniversalChartType.doughnut,
          UniversalChartType.pie,
        ],
      ),
      onChartTypeChanged: (type) {
        ref.read(chartDisplayProvider.notifier).setDistributionChartType(
              type == UniversalChartType.pie
                  ? DistributionChartType.pie
                  : DistributionChartType.doughnut,
            );
      },
      onFullscreenTap: () => context.pushNamed(
        FullscreenChartScreen.routeName,
        pathParameters: {'chartId': chartId},
      ),
      onPointTap: (index, point) {
        final item = SelectedChartItem(
          chartId: chartId,
          chartType: ChartType.productDistribution,
          dataIndex: index,
          label: point.label,
          value: point.value,
          unit: 'Units',
          secondaryMetric:
              '${((point.value / (totalUnits == 0 ? 1 : totalUnits)) * 100).toStringAsFixed(1)}% of Catalog',
          description: 'Total active SKUs in the ${point.label} department',
        );
        ref.read(chartInteractionProvider.notifier).selectItem(item);
        if (enableNavigation) {
          context.pushNamed(ChartDetailsScreen.routeName, extra: item);
        }
      },
    );
  }
}