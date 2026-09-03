import 'package:flutter/material.dart';

class SettingsActionTiles extends StatelessWidget {
  const SettingsActionTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;

        final tile1 = _ActionTile(
          iconBoxColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF3B82F6),
          title: 'Security Key Management',
          subtitle: 'Update MFA and auth tokens.',
          onTap: () {},
        );

        final tile2 = _ActionTile(
          iconBoxColor: const Color(0xFFFEF2F2),
          iconColor: const Color(0xFFEF4444),
          title: 'Active Session Audit',
          subtitle: 'Revoke access from 2 devices.',
          onTap: () {},
        );

        if (isNarrow) {
          return Column(children: [tile1, const SizedBox(height: 12), tile2]);
        }

        return Row(
          children: [
            Expanded(child: tile1),
            const SizedBox(width: 16),
            Expanded(child: tile2),
          ],
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.iconBoxColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color iconBoxColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBoxColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
