import 'package:flutter/material.dart';

import 'chart_type.dart';

/// Formatter callback converting raw numeric values into formatted display strings.
typedef ChartValueFormatter = String Function(double value);

/// Configuration options for [GlobalChartWidget].
class ChartConfig {
  const ChartConfig({
    required this.chartType,
    this.title,
    this.subtitle,
    this.height = 240.0,
    this.showLegend = false,
    this.showTooltip = true,
    this.showDataLabels = false,
    this.enableSelection = true,
    this.enableFullscreen = true,
    this.enableExport = true,
    this.enableChartTypeSwitching = true,
    this.supportedChartTypes = const [],
    this.targetValue,
    this.targetLabel = 'TARGET GOAL',
    this.xAxisTitle,
    this.yAxisTitle,
    this.showXAxis = true,
    this.showYAxis = true,
    this.valueFormatter,
    this.tooltipHeader,
    this.yAxisLabelFormat,
    this.primaryColor,
    this.accentColor,
    this.palette = const [
      Color(0xFF4F46E5),
      Color(0xFF059669),
      Color(0xFFD97706),
      Color(0xFF0284C7),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
    ],
  });

  final UniversalChartType chartType;
  final String? title;
  final String? subtitle;
  final double height;
  final bool showLegend;
  final bool showTooltip;
  final bool showDataLabels;
  final bool enableSelection;
  final bool enableFullscreen;
  final bool enableExport;
  final bool enableChartTypeSwitching;
  final List<UniversalChartType> supportedChartTypes;
  final double? targetValue;
  final String targetLabel;

  /// Custom X-axis title text.
  final String? xAxisTitle;

  /// Custom Y-axis title text.
  final String? yAxisTitle;

  /// Whether the X-axis should be rendered.
  final bool showXAxis;

  /// Whether the Y-axis should be rendered.
  final bool showYAxis;

  /// Reusable value formatting function (e.g. `(val) => 'Rs. ${val.toStringAsFixed(0)}'`).
  final ChartValueFormatter? valueFormatter;

  /// Optional custom tooltip header string or template.
  final String? tooltipHeader;

  /// Direct axis number label format string (e.g. `'Rs.{value}'` or `'{value}%'`).
  final String? yAxisLabelFormat;

  final Color? primaryColor;
  final Color? accentColor;
  final List<Color> palette;

  ChartConfig copyWith({
    UniversalChartType? chartType,
    String? title,
    String? subtitle,
    double? height,
    bool? showLegend,
    bool? showTooltip,
    bool? showDataLabels,
    bool? enableSelection,
    bool? enableFullscreen,
    bool? enableExport,
    bool? enableChartTypeSwitching,
    List<UniversalChartType>? supportedChartTypes,
    double? targetValue,
    String? targetLabel,
    String? xAxisTitle,
    String? yAxisTitle,
    bool? showXAxis,
    bool? showYAxis,
    ChartValueFormatter? valueFormatter,
    String? tooltipHeader,
    String? yAxisLabelFormat,
    Color? primaryColor,
    Color? accentColor,
    List<Color>? palette,
  }) {
    return ChartConfig(
      chartType: chartType ?? this.chartType,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      height: height ?? this.height,
      showLegend: showLegend ?? this.showLegend,
      showTooltip: showTooltip ?? this.showTooltip,
      showDataLabels: showDataLabels ?? this.showDataLabels,
      enableSelection: enableSelection ?? this.enableSelection,
      enableFullscreen: enableFullscreen ?? this.enableFullscreen,
      enableExport: enableExport ?? this.enableExport,
      enableChartTypeSwitching:
          enableChartTypeSwitching ?? this.enableChartTypeSwitching,
      supportedChartTypes: supportedChartTypes ?? this.supportedChartTypes,
      targetValue: targetValue ?? this.targetValue,
      targetLabel: targetLabel ?? this.targetLabel,
      xAxisTitle: xAxisTitle ?? this.xAxisTitle,
      yAxisTitle: yAxisTitle ?? this.yAxisTitle,
      showXAxis: showXAxis ?? this.showXAxis,
      showYAxis: showYAxis ?? this.showYAxis,
      valueFormatter: valueFormatter ?? this.valueFormatter,
      tooltipHeader: tooltipHeader ?? this.tooltipHeader,
      yAxisLabelFormat: yAxisLabelFormat ?? this.yAxisLabelFormat,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      palette: palette ?? this.palette,
    );
  }
}
