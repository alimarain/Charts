import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../domain/entities/chart_filter_models.dart';

class ChartKpiGrid extends StatelessWidget {
  const ChartKpiGrid({required this.kpis, super.key});

  final ComputedKpis kpis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;
        final cardWidth = isNarrow
            ? (constraints.maxWidth - 12) / 2
            : (constraints.maxWidth - 36) / 4;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _KpiMetricCard(
                title: 'Total Revenue',
                value:
                    'Rs. ${(kpis.currentRevenue / 1000).toStringAsFixed(1)}K',
                growth: kpis.revenueGrowthPercent,
                icon: Icons.payments_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiMetricCard(
                title: 'Order Volume',
                value: '${kpis.currentOrders}',
                growth: kpis.ordersGrowthPercent,
                icon: Icons.shopping_bag_rounded,
                color: AppTheme.secondaryColor,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiMetricCard(
                title: 'Active SKUs',
                value: '${kpis.activeSkus} Units',
                icon: Icons.inventory_2_rounded,
                color: AppTheme.accentColor,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiMetricCard(
                title: 'Target Pace',
                value: '${kpis.targetAchievementPercent.toStringAsFixed(0)}%',
                subtitle: kpis.targetAchievementPercent >= 100
                    ? 'On Track'
                    : 'Below Target',
                icon: Icons.track_changes_rounded,
                color: kpis.targetAchievementPercent >= 100
                    ? const Color(0xFF059669)
                    : const Color(0xFFD97706),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KpiMetricCard extends StatelessWidget {
  const _KpiMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.growth,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? growth;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final isPositive = (growth ?? 0) >= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          if (growth != null)
            Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 14,
                  color: isPositive
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${growth!.toStringAsFixed(1)}% vs prev',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPositive
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ],
            )
          else if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}
