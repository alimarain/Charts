import 'package:flutter/material.dart';

class PyramidMetric {
  const PyramidMetric({required this.stage, required this.value, this.color});

  final String stage;
  final double value;
  final Color? color;

  factory PyramidMetric.fromJson(Map<String, dynamic> json) {
    // 1. Strict String Rule: Dual-case lookup + explicit stringification + fallback
    final stage = (json['stage'] ?? json['Stage'] ?? '').toString();

    // 2. Strict double Rule: 3-tier extraction without direct casts
    final rawValue = json['value'] ?? json['Value'] ?? 0.0;
    final double value = rawValue is num
        ? rawValue.toDouble()
        : (double.tryParse(rawValue.toString()) ?? 0.0);

    return PyramidMetric(stage: stage, value: value);
  }

  Map<String, dynamic> toJson() {
    return {'stage': stage, 'value': value};
  }
}
