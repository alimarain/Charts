import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/app_theme.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/entities/chart_interaction.dart';
import '../../controllers/chart_interaction_provider.dart';
import '../../views/dashboard/chart_details_screen.dart';

class ProductDistributionChart extends ConsumerWidget {
  const ProductDistributionChart({
    required this.data,
    this.chartId = 'product_distribution_chart',
    this.enableNavigation = true,
    super.key,
  });

  final List<ProductDistributionData> data;
  final String chartId;
  final bool enableNavigation;

  static const List<Color> _chartPalette = [
    Color(0xFF4F46E5),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFF0284C7),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalUnits = data.fold<int>(0, (sum, item) => sum + item.count);
    final interactionState = ref.watch(chartInteractionProvider);
final selectedItem = interactionState.selectedItem;
final activeIndex = (selectedItem != null && selectedItem.chartId == chartId)
    ? selectedItem.dataIndex
    : 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory Allocation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap slices to inspect unit distribution',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 20,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: SfCircularChart(
                margin: EdgeInsets.zero,
                palette: _chartPalette,
                legend: const Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom,
                  textStyle: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y units',
                  color: AppTheme.textPrimary,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  animationDuration: 150,
                ),
                annotations: <CircularChartAnnotation>[
                  CircularChartAnnotation(
                    widget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalUnits',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Text(
                          'Total Units',
                          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
                series: <CircularSeries<ProductDistributionData, String>>[
                  DoughnutSeries<ProductDistributionData, String>(
                    dataSource: data,
                    xValueMapper: (ProductDistributionData dist, _) => dist.category,
                    yValueMapper: (ProductDistributionData dist, _) => dist.count,
                    dataLabelMapper: (ProductDistributionData dist, _) => '${dist.count}',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    innerRadius: '68%',
                    radius: '85%',
                    strokeColor: Colors.white,
                    strokeWidth: 2,
                    animationDuration: 400,
                    explode: true,
                    explodeGesture: ActivationMode.singleTap,
                    explodeOffset: '12%',
                    explodeIndex: activeIndex,
                    onPointTap: (ChartPointDetails details) {
                      if (details.pointIndex != null && details.pointIndex! < data.length) {
                        HapticFeedback.lightImpact();
                        final tapped = data[details.pointIndex!];
                        final item = SelectedChartItem(
                          chartId: chartId,
                          chartType: ChartType.productDistribution,
                          dataIndex: details.pointIndex!,
                          label: tapped.category,
                          value: tapped.count,
                          unit: 'Units',
                          secondaryMetric:
                              '${((tapped.count / totalUnits) * 100).toStringAsFixed(1)}% of Catalog',
                          description: 'Total active SKUs in the ${tapped.category} department',
                        );

                        ref.read(chartInteractionProvider.notifier).selectItem(item);

                        if (enableNavigation) {
                          context.pushNamed(ChartDetailsScreen.routeName, extra: item);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}