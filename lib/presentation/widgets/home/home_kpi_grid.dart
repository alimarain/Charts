import 'package:flutter/material.dart';

class HomeKpiGrid extends StatelessWidget {
  const HomeKpiGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isDesktop = availableWidth > 860;
        final cardWidth = isDesktop
            ? (availableWidth - 36) / 4
            : (availableWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _KpiTile(
              width: cardWidth,
              title: 'Operating Capital',
              value: 'USD 12.850.100,00',
              badgeText: '+8,4%',
              badgeBg: const Color(0xFFDCFCE7),
              badgeColor: const Color(0xFF15803D),
            ),
            _KpiTile(
              width: cardWidth,
              title: 'Active Allocations',
              value: '842 FTE',
              badgeText: '0,0%',
              badgeBg: const Color(0xFFF3F4F6),
              badgeColor: const Color(0xFF6B7280),
            ),
            _KpiTile(
              width: cardWidth,
              title: 'Average Latency',
              value: '42 ms',
              badgeText: '-12,3%',
              badgeBg: const Color(0xFFDCFCE7),
              badgeColor: const Color(0xFF15803D),
            ),
            _KpiTile(
              width: cardWidth,
              title: 'Risk Threshold',
              value: '12,4%',
              badgeText: '+2,1%',
              badgeBg: const Color(0xFFFCE7F3),
              badgeColor: const Color(0xFFBE185D),
            ),
          ],
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.width,
    required this.title,
    required this.value,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeColor,
  });

  final double width;
  final String title;
  final String value;
  final String badgeText;
  final Color badgeBg;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
