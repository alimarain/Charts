import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/analytics_export_service.dart';
import '../mappers/chart_data_mapper.dart';
import '../models/chart_config.dart';
import '../models/chart_data.dart';
import '../models/chart_series.dart';
import '../models/chart_type.dart';
import '../renderers/chart_renderer_factory.dart';
import 'components/chart_header_toolbar.dart';

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

  final List<T> data;
  final ChartDataMapper<T> mapper;
  final ChartConfig config;
  final List<T>? comparisonData;
  final ChartDataMapper<T>? comparisonMapper;
  final String comparisonSeriesName;
  final String? chartId;
  final void Function(int index, ChartDataPoint point)? onPointTap;
  final VoidCallback? onFullscreenTap;
  final ValueChanged<UniversalChartType>? onChartTypeChanged;
  final int? activeIndex;
  final bool isLoading;
  final String emptyMessage;
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
    final effectiveHeight = widget.isFullscreenMode ? 480.0 : widget.config.height;

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
              ChartHeaderToolbar(
                config: widget.config,
                activeChartType: _activeChartType,
                isFullscreenMode: widget.isFullscreenMode,
                onTypeSelected: _handleTypeSwitch,
                onExportImage: _exportImage,
                onFullscreenTap: widget.onFullscreenTap,
              ),
              if (widget.config.title != null) const SizedBox(height: 16),
              SizedBox(
                height: effectiveHeight,
                child: _buildChartCanvas(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCanvas() {
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
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    final dataPoints = widget.data.map(widget.mapper).toList();
    final List<ChartSeriesData> multiSeries = [];

    if (widget.comparisonData != null && widget.comparisonData!.isNotEmpty) {
      final compMapper = widget.comparisonMapper ?? widget.mapper;
      multiSeries.add(
        ChartSeriesData(
          name: widget.comparisonSeriesName,
          dataPoints: widget.comparisonData!.map(compMapper).toList(),
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
  }
}