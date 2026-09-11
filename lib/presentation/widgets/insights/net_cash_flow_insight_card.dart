import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../views/analytics/net_cashflow_screen.dart';
import 'insight_card_shell.dart';

class NetCashFlowInsightCard extends StatelessWidget {
  const NetCashFlowInsightCard({
    super.key,
    required this.netBalance,
    required this.inflow,
    required this.outflow,
  });

  final double netBalance;
  final double inflow;
  final double outflow;

  String _formatCompact(double val) {
    final abs = val.abs();
    if (abs >= 1000000) {
      return 'Rs. ${(abs / 1000000).toStringAsFixed(1)}M';
    }
    return 'Rs. ${(abs / 1000).toStringAsFixed(0)}K';
  }

  @override
  Widget build(BuildContext context) {
    final maxMetric = (inflow > outflow ? inflow : outflow);
    final safeMax = maxMetric > 0 ? maxMetric : 1.0;
    final inRatio = (inflow / safeMax).clamp(0.08, 1.0);
    final outRatio = (outflow / safeMax).clamp(0.08, 1.0);

    return InsightCardShell(
      onTap: () => context.push(NetCashflowScreen.routePath),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Net Cash Flow',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatCompact(netBalance),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // In Bar
          Row(
            children: [
              const SizedBox(
                width: 26,
                child: Text(
                  'In',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              Expanded(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: inRatio,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF009688),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Out Bar
          Row(
            children: [
              const SizedBox(
                width: 26,
                child: Text(
                  'Out',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              Expanded(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: outRatio,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD81B60),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
