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

class CategorySalesChart extends ConsumerWidget {
  const CategorySalesChart({
    required this.data,
    this.chartId = 'category_sales_chart',
    this.enableNavigation = true,
    super.key,
  });

  final List<CategorySalesData> data;
  final String chartId;
  final bool enableNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactionState = ref.watch(chartInteractionProvider);
final selectedItem = interactionState.selectedItem;
final activeIndex = (selectedItem != null && selectedItem.chartId == chartId)
    ? selectedItem.dataIndex
    : -1;

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
                      'Category Breakdown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap bars to view department telemetry',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 20,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                margin: EdgeInsets.zero,
                enableAxisAnimation: true,
                primaryXAxis: const CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  axisLine: AxisLine(width: 0.5, color: AppTheme.borderColor),
                  labelStyle: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  labelIntersectAction: AxisLabelIntersectAction.rotate45,
                ),
                primaryYAxis: const NumericAxis(
                  axisLine: AxisLine(width: 0),
                  majorGridLines: MajorGridLines(
                    dashArray: [4, 4],
                    color: AppTheme.borderColor,
                    width: 0.8,
                  ),
                  labelFormat: 'Rs.{value}',
                  labelStyle: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: '',
                  format: 'point.x: Rs.point.y',
                  color: AppTheme.textPrimary,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  animationDuration: 150,
                ),
                series: <CartesianSeries<CategorySalesData, String>>[
                  ColumnSeries<CategorySalesData, String>(
                    name: 'Revenue',
                    dataSource: data,
                    xValueMapper: (CategorySalesData item, _) => item.category,
                    yValueMapper: (CategorySalesData item, _) => item.sales,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    animationDuration: 400,
                    pointColorMapper: (CategorySalesData item, int index) {
                      if (activeIndex == index) {
                        return AppTheme.accentColor; // Highlighted color on selection
                      }
                      return const Color(0xFF059669);
                    },
                    onPointTap: (ChartPointDetails details) {
                      if (details.pointIndex != null && details.pointIndex! < data.length) {
                        HapticFeedback.lightImpact();
                        final tapped = data[details.pointIndex!];
                        final item = SelectedChartItem(
                          chartId: chartId,
                          chartType: ChartType.categoryPerformance,
                          dataIndex: details.pointIndex!,
                          label: tapped.category,
                          value: tapped.sales,
                          unit: 'PKR',
                          secondaryMetric: 'Active Stock Share',
                          description: 'Gross department order flow for ${tapped.category}',
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