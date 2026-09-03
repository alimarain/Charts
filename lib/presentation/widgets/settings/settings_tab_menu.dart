import 'package:flutter/material.dart';

class SettingsTabMenu extends StatelessWidget {
  const SettingsTabMenu({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final String selectedTab;
  final ValueChanged<String> onTabSelected;

  static const List<_TabItemData> _tabs = [
    _TabItemData(title: 'Account Profile', icon: null),
    _TabItemData(title: 'Security & SAML', icon: Icons.shield_outlined),
    _TabItemData(
      title: 'Notifications',
      icon: Icons.notifications_none_rounded,
    ),
    _TabItemData(title: 'Team Access', icon: Icons.group_outlined),
    _TabItemData(title: 'Billing & Usage', icon: Icons.credit_card_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _tabs.map((tab) {
        final isSelected = selectedTab == tab.title;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: InkWell(
            onTap: () => onTabSelected(tab.title),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: const Color(0xFFE5E7EB))
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  if (tab.icon != null) ...[
                    Icon(
                      tab.icon,
                      size: 16,
                      color: isSelected
                          ? const Color(0xFF111827)
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    tab.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF111827)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TabItemData {
  const _TabItemData({required this.title, required this.icon});
  final String title;
  final IconData? icon;
}
