import 'dart:ui';

/// A standardized, strongly typed data point consumed by all chart renderers.
///
/// Converts domain models into a normalized representation:
/// - [label] must be a [String].
/// - [value] must be a [double].
class ChartDataPoint {
  const ChartDataPoint({
    required this.label,
    required this.value,
    this.secondaryValue,
    this.targetValue,
    this.color,
    this.category,
    this.metadata,
  });

  /// The X-axis label or circular category slice name.
  final String label;

  /// The primary Y-axis magnitude or slice value (strictly typed as [double]).
  final double value;

  /// Optional baseline or comparison value (e.g. previous period).
  final double? secondaryValue;

  /// Optional goal or target threshold.
  final double? targetValue;

  /// Custom point color override.
  final Color? color;

  /// Optional grouping identifier.
  final String? category;

  /// Additional domain context for callbacks and drill-down details.
  final Object? metadata;

  ChartDataPoint copyWith({
    String? label,
    double? value,
    double? secondaryValue,
    double? targetValue,
    Color? color,
    String? category,
    Object? metadata,
  }) {
    return ChartDataPoint(
      label: label ?? this.label,
      value: value ?? this.value,
      secondaryValue: secondaryValue ?? this.secondaryValue,
      targetValue: targetValue ?? this.targetValue,
      color: color ?? this.color,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
    );
  }
}