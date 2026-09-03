import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.currentRoute,
    required this.hasToken,
    required this.userRole,
    this.isMobileDrawer = false,
  });

  final String currentRoute;
  final bool hasToken;
  final String userRole;
  final bool isMobileDrawer;

  static const Color sidebarBg = Color(0xFF1B1638);
  static const Color activePillBg = Color(0xFF2C2654);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobileDrawer ? 280 : 230,
      color: sidebarBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Logo Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.dashboard_customize_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'ENTERPRISEFLOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _NavItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Overview',
                    isActive: currentRoute == '/home',
                    onTap: () {
                      if (isMobileDrawer) Navigator.of(context).pop();
                      context.go('/home');
                    },
                  ),
                  const SizedBox(height: 4),
                  _NavItem(
                    icon: Icons.storefront_rounded,
                    label: 'Dashboard',
                    isActive: currentRoute.startsWith('/dashboard'),
                    onTap: () {
                      if (isMobileDrawer) Navigator.of(context).pop();
                      context.push('/dashboard');
                    },
                  ),
                  const SizedBox(height: 4),
                  _NavItem(
                    icon: Icons.insights_rounded,
                    label: 'Analytics',
                    isActive: currentRoute.startsWith('/charts'),
                    onTap: () {
                      if (isMobileDrawer) Navigator.of(context).pop();
                      context.push('/charts');
                    },
                  ),
                  const SizedBox(height: 4),
                  _NavItem(
                    icon: Icons.assignment_outlined,
                    label: 'Onboarding',
                    isActive: currentRoute == '/form',
                    onTap: () {
                      if (isMobileDrawer) Navigator.of(context).pop();
                      context.push('/form');
                    },
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    isActive: currentRoute == '/settings',
                    onTap: () {
                      if (isMobileDrawer) Navigator.of(context).pop();
                      context.push('/settings');
                    },
                  ),
                ],
              ),
            ),

            // Bottom API Status Box
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF130F2B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF28224E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 3.5,
                        backgroundColor: hasToken
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasToken ? 'API: Operational' : 'API: Disconnected',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasToken
                        ? 'Role session: $userRole'
                        : 'No active session token.',
                    style: const TextStyle(
                      color: Color(0xFF8E88AB),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2C2654) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF8E88AB),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFFCBD5E1),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
