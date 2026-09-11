import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'insight_card_shell.dart';

class ProfitEarnedCard extends StatelessWidget {
  const ProfitEarnedCard({
    super.key,
    this.amount = 450000,
    this.accountsPercent = 0.65,
    this.mudarabahPercent = 0.35,
    this.onTap,
  });

  final double amount;
  final double accountsPercent;
  final double mudarabahPercent;
  final VoidCallback? onTap;

  static const Color accountsColor = Color(0xFF00897B);
  static const Color mudarabahColor = Color(0xFF4DB6AC);

  @override
  Widget build(BuildContext context) {
    return InsightCardShell(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profit analytics coming soon.')),
            );
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profit Earned',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rs. ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Donut Ring and Legend Split
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _LegendDot(label: 'Accounts', color: accountsColor),
                  SizedBox(height: 6),
                  _LegendDot(label: 'Mudarabah', color: mudarabahColor),
                ],
              ),
              CustomPaint(
                size: const Size(40, 40),
                painter: _SplitDonutPainter(
                  primaryRatio: accountsPercent,
                  primaryColor: accountsColor,
                  secondaryColor: mudarabahColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _SplitDonutPainter extends CustomPainter {
  _SplitDonutPainter({
    required this.primaryRatio,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final double primaryRatio;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final strokeWidth = 5.5;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepPrimary = 2 * math.pi * primaryRatio;
    final sweepSecondary = 2 * math.pi * (1.0 - primaryRatio);

    basePaint.color = primaryColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepPrimary - 0.1,
      false,
      basePaint,
    );

    basePaint.color = secondaryColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + sweepPrimary + 0.1,
      sweepSecondary - 0.2,
      false,
      basePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SplitDonutPainter oldDelegate) =>
      oldDelegate.primaryRatio != primaryRatio;
}
