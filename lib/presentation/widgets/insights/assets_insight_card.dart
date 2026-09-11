import 'package:flutter/material.dart';

import 'insight_card_shell.dart';

class AssetsInsightCard extends StatelessWidget {
  const AssetsInsightCard({
    super.key,
    this.totalAssets = 8250000,
    this.accountRatio = 0.60, // 60%
    this.mudarabahRatio = 0.40, // 40%
    this.onTap,
  });

  final double totalAssets;
  final double accountRatio;
  final double mudarabahRatio;
  final VoidCallback? onTap;

  static const Color accountColor = Color(0xFF00897B);
  static const Color mudarabahColor = Color(0xFF4DB6AC);

  @override
  Widget build(BuildContext context) {
    return InsightCardShell(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Asset portfolio view coming soon.'),
              ),
            );
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assets',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs. ${totalAssets.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Dual-segment Allocation Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 7,
              child: Row(
                children: [
                  Expanded(
                    flex: (accountRatio * 100).round(),
                    child: Container(color: accountColor),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    flex: (mudarabahRatio * 100).round(),
                    child: Container(color: mudarabahColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            children: [
              _DotLegend(label: 'Account', color: accountColor),
              const SizedBox(width: 24),
              _DotLegend(label: 'Mudarabah', color: mudarabahColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotLegend extends StatelessWidget {
  const _DotLegend({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
