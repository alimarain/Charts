import 'package:flutter/material.dart';

import '../../../../domain/entities/basic_chart_data.dart';

class MetricDetailSheet extends StatelessWidget {
  const MetricDetailSheet({super.key, required this.point});

  final BasicChartData point;

  static void show(BuildContext context, BasicChartData point) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => MetricDetailSheet(point: point),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variance = point.sales - point.target;
    final isPositive = variance >= 0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metric Details: ${point.month}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  point.growthTag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isPositive
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Actual Volume',
            value: 'PKR ${point.sales.toStringAsFixed(0)}',
          ),
          _DetailRow(
            label: 'Target Baseline',
            value: 'PKR ${point.target.toStringAsFixed(0)}',
          ),
          _DetailRow(
            label: 'Variance',
            value: '${isPositive ? "+" : ""}PKR ${variance.toStringAsFixed(0)}',
            valueColor: isPositive
                ? const Color(0xFF15803D)
                : const Color(0xFFB91C1C),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: valueColor ?? const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
