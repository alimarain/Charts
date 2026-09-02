import 'package:flutter/material.dart';

class PyramidMetric {
  final String stage;
  final double value;
  final Color? color;

  const PyramidMetric({
    required this.stage,
    required this.value,
    this.color,
  });

  /// Factory constructor to parse backend JSON from REST or SignalR
  factory PyramidMetric.fromJson(Map<String, dynamic> json) {
    return PyramidMetric(
      stage: (json['stage'] ?? json['Stage'] ?? '').toString(),
      value: (json['value'] ?? json['Value'] ?? 0.0) is num
          ? (json['value'] ?? json['Value'] as num).toDouble()
          : double.tryParse((json['value'] ?? json['Value'] ?? '0').toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'value': value,
    };
  }
}