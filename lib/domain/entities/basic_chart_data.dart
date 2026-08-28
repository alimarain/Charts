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
}