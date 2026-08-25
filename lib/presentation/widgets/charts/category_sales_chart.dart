import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/widgets/charts/fullscreen_chart_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../app/app_theme.dart';
import '../../../core/services/analytics_export_service.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/entities/chart_display_models.dart';
import '../../../domain/entities/chart_interaction.dart';
import '../../controllers/chart_display_provider.dart';
import '../../controllers/chart_interaction_provider.dart';
import '../../views/dashboard/chart_details_screen.dart';

class CategorySalesChart extends ConsumerStatefulWidget {
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
  ConsumerState<CategorySalesChart> createState() => _CategorySalesChartState();
}

class _CategorySalesChartState extends ConsumerState<CategorySalesChart> {
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _handleMenuAction(String action, BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    switch (action) {
      case 'fullscreen':
        context.pushNamed(
          FullscreenChartScreen.routeName,
          pathParameters: {'chartId': widget.chartId},
        );
        break;
      case 'type_column':
        ref
            .read(chartDisplayProvider.notifier)
            .setCategoryChartType(CategoryChartType.column);
        break;
      case 'type_bar':
        ref
            .read(chartDisplayProvider.notifier)
            .setCategoryChartType(CategoryChartType.bar);
        break;
      case 'export_image':
        try {
          scaffold.showSnackBar(
            const SnackBar(content: Text('Preparing chart image...')),
          );
          await AnalyticsExportService.exportAndShareImage(
            boundaryKey: _boundaryKey,
            chartName: 'Category-Breakdown',
          );
        } catch (e) {
          scaffold.showSnackBar(
            SnackBar(content: Text('Could not export chart image: $e')),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayState = ref.watch(chartDisplayProvider);
    final interactionState = ref.watch(chartInteractionProvider);
    final selectedItem = interactionState.selectedItem;
    final activeIndex =
        (selectedItem != null && selectedItem.chartId == widget.chartId)
            ? selectedItem.dataIndex
            : -1;

    final isBar = displayState.categoryChartType == CategoryChartType.bar;

    return RepaintBoundary(
      key: _boundaryKey,
      child: Card(
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
                  Row(
                    children: [
                      if (!widget.isFullscreenMode)
                        IconButton(
                          icon: const Icon(Icons.fullscreen_rounded,
                              size: 20, color: AppTheme.textSecondary),
                          tooltip: 'Full Screen View',
                          onPressed: () => _handleMenuAction('fullscreen', context),
                        ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            size: 20, color: AppTheme.textSecondary),
                        onSelected: (val) => _handleMenuAction(val, context),
                        itemBuilder: (ctx) => [
                          if (!widget.isFullscreenMode)
                            const PopupMenuItem(
                              value: 'fullscreen',
                              child: Row(
                                children: [
                                  Icon(Icons.fullscreen, size: 16),
                                  SizedBox(width: 8),
                                  Text('View Full Screen'),
                                ],
                              ),
                            ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'type_column',
                            child: Text('Chart Type: Vertical Column'),
                          ),
                          const PopupMenuItem(
                            value: 'type_bar',
                            child: Text('Chart Type: Horizontal Bar'),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'export_image',
                            child: Row(
                              children: [
                                Icon(Icons.image_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('Export Chart Image'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: widget.isFullscreenMode ? 480 : 240,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: EdgeInsets.zero,
                  enableAxisAnimation: true,
                  isTransposed: isBar,
                  primaryXAxis: const CategoryAxis(
                    majorGridLines: MajorGridLines(width: 0),
                    axisLine: AxisLine(width: 0.5, color: AppTheme.borderColor),
                    labelStyle: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
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
                  ),
                  series: <CartesianSeries<CategorySalesData, String>>[
                    isBar
                        ? BarSeries<CategorySalesData, String>(
                            name: 'Revenue',
                            dataSource: widget.data,
                            xValueMapper: (CategorySalesData item, _) => item.category,
                            yValueMapper: (CategorySalesData item, _) => item.sales,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                            pointColorMapper: (CategorySalesData item, int idx) =>
                                activeIndex == idx ? AppTheme.accentColor : const Color(0xFF059669),
                            onPointTap: (details) => _onTapPoint(details),
                          )
                        : ColumnSeries<CategorySalesData, String>(
                            name: 'Revenue',
                            dataSource: widget.data,
                            xValueMapper: (CategorySalesData item, _) => item.category,
                            yValueMapper: (CategorySalesData item, _) => item.sales,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            pointColorMapper: (CategorySalesData item, int idx) =>
                                activeIndex == idx ? AppTheme.accentColor : const Color(0xFF059669),
                            onPointTap: (details) => _onTapPoint(details),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapPoint(ChartPointDetails details) {
    if (details.pointIndex != null && details.pointIndex! < widget.data.length) {
      HapticFeedback.lightImpact();
      final tapped = widget.data[details.pointIndex!];
      final item = SelectedChartItem(
        chartId: widget.chartId,
        chartType: ChartType.categoryPerformance,
        dataIndex: details.pointIndex!,
        label: tapped.category,
        value: tapped.sales,
        unit: 'PKR',
        secondaryMetric: 'Active Stock Share',
        description: 'Gross department order flow for ${tapped.category}',
      );

      ref.read(chartInteractionProvider.notifier).selectItem(item);

      if (widget.enableNavigation) {
        context.pushNamed(ChartDetailsScreen.routeName, extra: item);
      }
    }
  }
}