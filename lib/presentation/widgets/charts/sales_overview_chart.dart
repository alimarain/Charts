import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/app_theme.dart';
import 'package:new_app/presentation/views/dashboard/chart_details_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/entities/chart_interaction.dart';
import '../../controllers/chart_interaction_provider.dart';

class SalesOverviewChart extends ConsumerWidget {
  const SalesOverviewChart({
    required this.data,
    this.chartId = 'sales_overview_chart',
    this.enableNavigation = true,
    super.key,
  });

  final List<SalesData> data;
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
                      'Revenue Velocity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap points to inspect day telemetry',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    size: 20,
                    color: AppTheme.primaryColor,
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
                  labelStyle: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
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
                  canShowMarker: true,
                  format: 'point.x: Rs.point.y',
                  color: AppTheme.textPrimary,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  animationDuration: 200,
                ),
                series: <CartesianSeries<SalesData, String>>[
                  SplineAreaSeries<SalesData, String>(
                    name: 'Revenue',
                    dataSource: data,
                    xValueMapper: (SalesData sales, _) => sales.label,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    borderColor: AppTheme.primaryColor,
                    borderWidth: 2.5,
                    animationDuration: 400,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.35),
                        AppTheme.primaryColor.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      height: 8,
                      width: 8,
                      shape: DataMarkerType.circle,
                      color: activeIndex >= 0 ? AppTheme.accentColor : AppTheme.primaryColor,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                    onPointTap: (ChartPointDetails details) {
                      if (details.pointIndex != null && details.pointIndex! < data.length) {
                        HapticFeedback.lightImpact();
                        final tappedData = data[details.pointIndex!];
                        final item = SelectedChartItem(
                          chartId: chartId,
                          chartType: ChartType.salesOverview,
                          dataIndex: details.pointIndex!,
                          label: tappedData.label,
                          value: tappedData.value,
                          unit: 'PKR',
                          secondaryMetric: '+14% vs last cycle',
                          description: 'Daily gross checkout run rate for ${tappedData.label}',
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