import 'package:flutter/material.dart';

class NetBalanceMetricHeader extends StatelessWidget {
  const NetBalanceMetricHeader({
    super.key,
    required this.inflow,
    required this.outflow,
    required this.isFiltered,
    required this.onReset,
  });

  final double inflow;
  final double outflow;
  final bool isFiltered;
  final VoidCallback onReset;

  static const Color teal = Color(0xFF009688);
  static const Color crimson = Color(0xFFD81B60);

  String _format(double v) =>
      'Rs. ${v.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String _compact(double v) => 'RS. ${(v.abs() / 1000).toStringAsFixed(0)}K';

  @override
  Widget build(BuildContext context) {
    final net = inflow - outflow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Net Balance',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${net < 0 ? "-" : ""}${_format(net)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
            if (isFiltered)
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.close_rounded, size: 14),
                label: const Text('Reset', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _Badge(
              label: _compact(inflow),
              icon: Icons.north_east_rounded,
              color: teal,
              bg: const Color(0xFFE0F2F1),
            ),
            const SizedBox(width: 10),
            _Badge(
              label: _compact(outflow),
              icon: Icons.south_west_rounded,
              color: crimson,
              bg: const Color(0xFFFCE4EC),
            ),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
