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
import '../../../domain/entities/chart_filter_models.dart';
import '../../../domain/entities/chart_interaction.dart';
import '../../controllers/chart_display_provider.dart';
import '../../controllers/chart_filter_provider.dart';
import '../../controllers/chart_interaction_provider.dart';
import '../../views/dashboard/chart_details_screen.dart';

class SalesOverviewChart extends ConsumerStatefulWidget {
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
  ConsumerState<SalesOverviewChart> createState() => _SalesOverviewChartState();
}

class _SalesOverviewChartState extends ConsumerState<SalesOverviewChart> {
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
      case 'type_area':
        ref
            .read(chartDisplayProvider.notifier)
            .setRevenueChartType(RevenueChartType.splineArea);
        break;
      case 'type_line':
        ref
            .read(chartDisplayProvider.notifier)
            .setRevenueChartType(RevenueChartType.line);
        break;
      case 'type_column':
        ref
            .read(chartDisplayProvider.notifier)
            .setRevenueChartType(RevenueChartType.column);
        break;
      case 'export_image':
        try {
          scaffold.showSnackBar(
            const SnackBar(content: Text('Preparing chart image...')),
          );
          await AnalyticsExportService.exportAndShareImage(
            boundaryKey: _boundaryKey,
            chartName: 'Revenue-Velocity',
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
    final filter = ref.watch(chartFilterProvider);
    final displayState = ref.watch(chartDisplayProvider);
    final interactionState = ref.watch(chartInteractionProvider);
    final selectedItem = interactionState.selectedItem;
    final activeIndex =
        (selectedItem != null && selectedItem.chartId == widget.chartId)
            ? selectedItem.dataIndex
            : -1;

    final showComparison = filter.comparisonPeriod != ComparisonPeriod.none &&
        widget.previousData.isNotEmpty;

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revenue Velocity & Comparisons',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        filter.isTargetEnabled
                            ? 'Target: Rs. ${(filter.targetRevenue / 1000).toStringAsFixed(0)}K · Tap point to inspect'
                            : 'Tap point to inspect',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
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
                            value: 'type_area',
                            child: Text('Chart Type: Spline Area'),
                          ),
                          const PopupMenuItem(
                            value: 'type_line',
                            child: Text('Chart Type: Line'),
                          ),
                          const PopupMenuItem(
                            value: 'type_column',
                            child: Text('Chart Type: Column'),
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
                  legend: Legend(
                    isVisible: showComparison,
                    position: LegendPosition.top,
                    overflowMode: LegendItemOverflowMode.wrap,
                    textStyle: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  primaryXAxis: const CategoryAxis(
                    majorGridLines: MajorGridLines(width: 0),
                    axisLine: AxisLine(width: 0.5, color: AppTheme.borderColor),
                    labelStyle: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 0),
                    majorGridLines: const MajorGridLines(
                      dashArray: [4, 4],
                      color: AppTheme.borderColor,
                      width: 0.8,
                    ),
                    plotBands: filter.isTargetEnabled
                        ? [
                            PlotBand(
                              isVisible: true,
                              start: filter.targetRevenue / 7,
                              end: filter.targetRevenue / 7,
                              borderColor: const Color(0xFFEF4444),
                              borderWidth: 2,
                              dashArray: const [6, 4],
                              text: 'TARGET GOAL',
                              textStyle: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                              horizontalTextAlignment: TextAnchor.end,
                              verticalTextAlignment: TextAnchor.start,
                            ),
                          ]
                        : const [],
                    labelFormat: 'Rs.{value}',
                    labelStyle: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    header: '',
                    canShowMarker: true,
                    format: 'point.x : Rs.point.y',
                    color: AppTheme.textPrimary,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  series: <CartesianSeries<SalesData, String>>[
                    if (showComparison)
                      SplineSeries<SalesData, String>(
                        name: 'Previous Period',
                        dataSource: widget.previousData,
                        xValueMapper: (SalesData s, _) => s.label,
                        yValueMapper: (SalesData s, _) => s.value,
                        color: const Color(0xFF94A3B8),
                        width: 2,
                        dashArray: const [5, 5],
                      ),
                    ..._buildActiveSeries(
                      displayState.revenueChartType,
                      widget.data,
                      activeIndex,
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

  List<CartesianSeries<SalesData, String>> _buildActiveSeries(
    RevenueChartType type,
    List<SalesData> seriesData,
    int activeIndex,
  ) {
    void onTapCallback(ChartPointDetails details) {
      if (details.pointIndex != null && details.pointIndex! < seriesData.length) {
        HapticFeedback.lightImpact();
        final filter = ref.read(chartFilterProvider);
        final tapped = seriesData[details.pointIndex!];
        final item = SelectedChartItem(
          chartId: widget.chartId,
          chartType: ChartType.salesOverview,
          dataIndex: details.pointIndex!,
          label: tapped.label,
          value: tapped.value,
          unit: 'PKR',
          secondaryMetric:
              '${filter.selectedCategory} · ${filter.datePreset.name}',
          description:
              'Gross checkout run rate for ${tapped.label} within the current filter scope',
        );

        ref.read(chartInteractionProvider.notifier).selectItem(item);

        if (widget.enableNavigation) {
          context.pushNamed(ChartDetailsScreen.routeName, extra: item);
        }
      }
    }

    switch (type) {
      case RevenueChartType.line:
        return [
          LineSeries<SalesData, String>(
            name: 'Current Period',
            dataSource: seriesData,
            xValueMapper: (SalesData s, _) => s.label,
            yValueMapper: (SalesData s, _) => s.value,
            color: AppTheme.primaryColor,
            width: 3,
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 8,
              width: 8,
              shape: DataMarkerType.circle,
              color: activeIndex >= 0 ? AppTheme.accentColor : AppTheme.primaryColor,
            ),
            onPointTap: onTapCallback,
          )
        ];
      case RevenueChartType.column:
        return [
          ColumnSeries<SalesData, String>(
            name: 'Current Period',
            dataSource: seriesData,
            xValueMapper: (SalesData s, _) => s.label,
            yValueMapper: (SalesData s, _) => s.value,
            color: AppTheme.primaryColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            onPointTap: onTapCallback,
          )
        ];
      case RevenueChartType.splineArea:
      default:
        return [
          SplineAreaSeries<SalesData, String>(
            name: 'Current Period',
            dataSource: seriesData,
            xValueMapper: (SalesData s, _) => s.label,
            yValueMapper: (SalesData s, _) => s.value,
            borderColor: AppTheme.primaryColor,
            borderWidth: 2.5,
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
            onPointTap: onTapCallback,
          )
        ];
    }
  }
}