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

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    Color? parsedColor;
    if (json['color'] is String) {
      final hex = (json['color'] as String).replaceAll('#', '');
      if (hex.length == 6) {
        parsedColor = Color(int.parse('0xFF$hex'));
      } else if (hex.length == 8) {
        parsedColor = Color(int.parse('0x$hex'));
      }
    } else if (json['color'] is int) {
      parsedColor = Color(json['color'] as int);
    }

    return ChartDataPoint(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      secondaryValue: (json['secondaryValue'] as num?)?.toDouble(),
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      color: parsedColor,
      category: json['category'] as String?,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      if (secondaryValue != null) 'secondaryValue': secondaryValue,
      if (targetValue != null) 'targetValue': targetValue,
      if (color != null) 'color': '#${color!.toARGB32().toRadixString(16).padLeft(8, '0')}',
      if (category != null) 'category': category,
      if (metadata != null) 'metadata': metadata,
    };
  }

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