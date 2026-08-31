import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chart_config.dart';
import '../models/chart_data.dart';
import '../models/chart_series.dart';
import '../models/chart_type.dart';
import '../mappers/chart_data_mapper.dart';
import '../renderers/chart_renderer_factory.dart';
import '../../services/analytics_export_service.dart';

/// Single public entry point for rendering all charts across the application.
class GlobalChartWidget<T> extends StatefulWidget {
  const GlobalChartWidget({
    required this.data,
    required this.mapper,
    required this.config,
    this.comparisonData,
    this.comparisonMapper,
    this.comparisonSeriesName = 'Previous Period',
    this.chartId,
    this.onPointTap,
    this.onFullscreenTap,
    this.onChartTypeChanged,
    this.activeIndex,
    this.isLoading = false,
    this.emptyMessage = 'No chart data available.',
    this.isFullscreenMode = false,
    super.key,
  });

  /// Generic domain dataset.
  final List<T> data;

  /// Transformation callback converting [T] into a standardized [ChartDataPoint].
  final ChartDataMapper<T> mapper;

  /// Presentation and feature configuration.
  final ChartConfig config;

  /// Optional comparison domain dataset.
  final List<T>? comparisonData;

  /// Optional mapper for comparison dataset (defaults to [mapper] if omitted).
  final ChartDataMapper<T>? comparisonMapper;

  /// Legend label for comparison series.
  final String comparisonSeriesName;

  /// Stable chart identifier.
  final String? chartId;

  /// Application-level point tap callback (receives data index and normalized point).
  final void Function(int index, ChartDataPoint point)? onPointTap;

  /// Fullscreen action callback.
  final VoidCallback? onFullscreenTap;

  /// Chart type switch callback.
  final ValueChanged<UniversalChartType>? onChartTypeChanged;

  /// External active highlighted point index (if null, internal selection is used).
  final int? activeIndex;

  /// Whether the chart is in a loading state.
  final bool isLoading;

  /// Custom message displayed when data is empty.
  final String emptyMessage;

  /// Whether the chart is rendered inside a fullscreen viewport.
  final bool isFullscreenMode;

  @override
  State<GlobalChartWidget<T>> createState() => _GlobalChartWidgetState<T>();
}

class _GlobalChartWidgetState<T> extends State<GlobalChartWidget<T>> {
  final GlobalKey _boundaryKey = GlobalKey();
  late UniversalChartType _activeChartType;
  int _internalActiveIndex = -1;

  @override
  void initState() {
    super.initState();
    _activeChartType = widget.config.chartType;
    _internalActiveIndex = widget.activeIndex ?? -1;
  }

  @override
  void didUpdateWidget(covariant GlobalChartWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.chartType != widget.config.chartType) {
      _activeChartType = widget.config.chartType;
    }
    if (widget.activeIndex != null && widget.activeIndex != oldWidget.activeIndex) {
      _internalActiveIndex = widget.activeIndex!;
    }
  }

  void _handleTypeSwitch(UniversalChartType newType) {
    setState(() => _activeChartType = newType);
    widget.onChartTypeChanged?.call(newType);
  }

  Future<void> _exportImage() async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Preparing chart image...')),
      );
      await AnalyticsExportService.exportAndShareImage(
        boundaryKey: _boundaryKey,
        chartName: widget.config.title?.replaceAll(' ', '-') ?? 'Chart-Export',
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Could not export chart image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double effectiveHeight =
        widget.isFullscreenMode ? 480.0 : widget.config.height;

    return RepaintBoundary(
      key: _boundaryKey,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Action Toolbar
              if (widget.config.title != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.config.title!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (widget.config.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.config.subtitle!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.config.enableFullscreen &&
                            !widget.isFullscreenMode &&
                            widget.onFullscreenTap != null)
                          IconButton(
                            icon: const Icon(Icons.fullscreen_rounded,
                                size: 20, color: Color(0xFF64748B)),
                            tooltip: 'Full Screen View',
                            onPressed: widget.onFullscreenTap,
                          ),
                        if (widget.config.enableChartTypeSwitching ||
                            widget.config.enableExport)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded,
                                size: 20, color: Color(0xFF64748B)),
                            onSelected: (action) {
                              if (action == 'fullscreen') {
                                widget.onFullscreenTap?.call();
                              } else if (action == 'export_image') {
                                _exportImage();
                              } else if (action.startsWith('type_')) {
                                final typeName = action.replaceFirst('type_', '');
                                final match = UniversalChartType.values.firstWhere(
                                  (e) => e.name == typeName,
                                  orElse: () => _activeChartType,
                                );
                                _handleTypeSwitch(match);
                              }
                            },
                            itemBuilder: (ctx) => [
                              if (widget.config.enableFullscreen &&
                                  !widget.isFullscreenMode &&
                                  widget.onFullscreenTap != null)
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
                              if (widget.config.supportedChartTypes.isNotEmpty) ...[
                                const PopupMenuDivider(),
                                ...widget.config.supportedChartTypes.map(
                                  (type) => PopupMenuItem(
                                    value: 'type_${type.name}',
                                    child: Text('Chart Type: ${type.name.toUpperCase()}'),
                                  ),
                                ),
                              ],
                              if (widget.config.enableExport) ...[
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
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Reusable Loading / Empty State or Canvas
              SizedBox(
                height: effectiveHeight,
                child: Builder(
                  builder: (context) {
                    if (widget.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF4F46E5),
                        ),
                      );
                    }

                    if (widget.data.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bar_chart_outlined,
                              size: 36,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.emptyMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // 1. Transform generic domain data to universal standard
                    final List<ChartDataPoint> dataPoints =
                        widget.data.map(widget.mapper).toList();

                    // 2. Transform secondary/comparison data if present
                    final List<ChartSeriesData> multiSeries = [];
                    if (widget.comparisonData != null &&
                        widget.comparisonData!.isNotEmpty) {
                      final compMapper =
                          widget.comparisonMapper ?? widget.mapper;
                      multiSeries.add(
                        ChartSeriesData(
                          name: widget.comparisonSeriesName,
                          dataPoints:
                              widget.comparisonData!.map(compMapper).toList(),
                          isSecondary: true,
                        ),
                      );
                    }

                    return ChartRendererFactory.buildChart(
                      type: _activeChartType,
                      dataPoints: dataPoints,
                      config: widget.config,
                      activeIndex: widget.activeIndex ?? _internalActiveIndex,
                      isFullscreen: widget.isFullscreenMode,
                      multiSeries: multiSeries,
                      onPointTapped: (index, point) {
                        HapticFeedback.lightImpact();
                        if (widget.config.enableSelection) {
                          setState(() => _internalActiveIndex = index);
                        }
                        widget.onPointTap?.call(index, point);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}