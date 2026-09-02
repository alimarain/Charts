import 'package:flutter/material.dart';

class BasicChartData {
  const BasicChartData({
    required this.month,
    required this.sales,
    required this.color,
    this.target = 20000.0,
    this.growthTag = '+12%',
  });

  final String month;
  final double sales;
  final Color color;
  final double target;
  final String growthTag;

  /// Default color palette used when backend does not supply explicit colors
  static const List<Color> _defaultPalette = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF3B82F6), // Blue
  ];

  /// Factory constructor to parse JSON payloads from both REST API and SignalR WebSockets.
  /// Handles both camelCase and PascalCase DTO properties from ASP.NET Core.
  factory BasicChartData.fromJson(Map<String, dynamic> json, [int index = 0]) {
    // 1. Parse month/label
    final month = (json['month'] ?? json['Month'] ?? '').toString();

    // 2. Parse sales amount safely
    final rawSales = json['sales'] ?? json['Sales'] ?? 0.0;
    final sales = rawSales is num
        ? rawSales.toDouble()
        : (double.tryParse(rawSales.toString()) ?? 0.0);

    // 3. Parse target
    final rawTarget = json['target'] ?? json['Target'] ?? 20000.0;
    final target = rawTarget is num
        ? rawTarget.toDouble()
        : (double.tryParse(rawTarget.toString()) ?? 20000.0);

    // 4. Parse growth tag
    final growthTag = (json['growthTag'] ?? json['GrowthTag'] ?? '+12%').toString();

    // 5. Parse or compute Color
    Color color = _defaultPalette[index % _defaultPalette.length];
    final colorVal = json['color'] ?? json['Color'];
    if (colorVal is int) {
      color = Color(colorVal);
    } else if (colorVal is String && colorVal.startsWith('#')) {
      final hex = colorVal.replaceAll('#', '');
      if (hex.length == 6) {
        color = Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        color = Color(int.parse(hex, radix: 16));
      }
    }

    return BasicChartData(
      month: month,
      sales: sales,
      color: color,
      target: target,
      growthTag: growthTag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'sales': sales,
      'color': '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}',
      'target': target,
      'growthTag': growthTag,
    };
  }
}