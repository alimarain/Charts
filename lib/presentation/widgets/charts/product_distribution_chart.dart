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

class ProductDistributionChart extends ConsumerStatefulWidget {
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

  static const List<Color> _chartPalette = [
    Color(0xFF4F46E5),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFF0284C7),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  @override
  ConsumerState<ProductDistributionChart> createState() =>
      _ProductDistributionChartState();
}

class _ProductDistributionChartState
    extends ConsumerState<ProductDistributionChart> {
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
      case 'type_doughnut':
        ref
            .read(chartDisplayProvider.notifier)
            .setDistributionChartType(DistributionChartType.doughnut);
        break;
      case 'type_pie':
        ref
            .read(chartDisplayProvider.notifier)
            .setDistributionChartType(DistributionChartType.pie);
        break;
      case 'export_image':
        try {
          scaffold.showSnackBar(
            const SnackBar(content: Text('Preparing chart image...')),
          );
          await AnalyticsExportService.exportAndShareImage(
            boundaryKey: _boundaryKey,
            chartName: 'Product-Distribution',
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
    final totalUnits =
        widget.data.fold<int>(0, (sum, item) => sum + item.count);
    final displayState = ref.watch(chartDisplayProvider);
    final interactionState = ref.watch(chartInteractionProvider);
    final selectedItem = interactionState.selectedItem;
    final activeIndex =
        (selectedItem != null && selectedItem.chartId == widget.chartId)
            ? selectedItem.dataIndex
            : 0;

    final isPie =
        displayState.distributionChartType == DistributionChartType.pie;

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
                            value: 'type_doughnut',
                            child: Text('Chart Type: Doughnut'),
                          ),
                          const PopupMenuItem(
                            value: 'type_pie',
                            child: Text('Chart Type: Pie'),
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
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  palette: ProductDistributionChart._chartPalette,
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
                  ),
                  annotations: isPie
                      ? const []
                      : <CircularChartAnnotation>[
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
                                  style: TextStyle(
                                      fontSize: 10, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                  series: <CircularSeries<ProductDistributionData, String>>[
                    isPie
                        ? PieSeries<ProductDistributionData, String>(
                            dataSource: widget.data,
                            xValueMapper: (ProductDistributionData dist, _) =>
                                dist.category,
                            yValueMapper: (ProductDistributionData dist, _) =>
                                dist.count,
                            dataLabelMapper: (ProductDistributionData dist, _) =>
                                '${dist.count}',
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary),
                            ),
                            explode: true,
                            explodeIndex: activeIndex,
                            onPointTap: (details) => _onTapSlice(details, totalUnits),
                          )
                        : DoughnutSeries<ProductDistributionData, String>(
                            dataSource: widget.data,
                            xValueMapper: (ProductDistributionData dist, _) =>
                                dist.category,
                            yValueMapper: (ProductDistributionData dist, _) =>
                                dist.count,
                            dataLabelMapper: (ProductDistributionData dist, _) =>
                                '${dist.count}',
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                              textStyle: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary),
                            ),
                            innerRadius: '68%',
                            radius: '85%',
                            strokeColor: Colors.white,
                            strokeWidth: 2,
                            explode: true,
                            explodeIndex: activeIndex,
                            onPointTap: (details) => _onTapSlice(details, totalUnits),
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

  void _onTapSlice(ChartPointDetails details, int totalUnits) {
    if (details.pointIndex != null && details.pointIndex! < widget.data.length) {
      HapticFeedback.lightImpact();
      final tapped = widget.data[details.pointIndex!];
      final item = SelectedChartItem(
        chartId: widget.chartId,
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

      if (widget.enableNavigation) {
        context.pushNamed(ChartDetailsScreen.routeName, extra: item);
      }
    }
  }
}