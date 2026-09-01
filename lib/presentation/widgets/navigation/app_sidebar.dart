import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.currentRoute,
    required this.hasToken,
    required this.userRole,
  });

  final String currentRoute;
  final bool hasToken;
  final String userRole;

  static const Color sidebarBg = Color(0xFF1B1638);
  static const Color activePillBg = Color(0xFF2C2654);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final sidebarWidth = isDesktop ? 220.0 : 72.0;

    return Container(
      width: sidebarWidth,
      color: sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Logo
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: isDesktop ? Alignment.centerLeft : Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.dashboard_customize_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 10),
                  const Text(
                    'ENTERPRISEFLOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Overview',
                  isActive: currentRoute == '/home',
                  isDesktop: isDesktop,
                  onTap: () => context.go('/home'),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.storefront_rounded,
                  label: 'Dashboard',
                  isActive: currentRoute.startsWith('/dashboard'),
                  isDesktop: isDesktop,
                  onTap: () => context.push('/dashboard'),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.insights_rounded,
                  label: 'Analytics',
                  isActive: currentRoute.startsWith('/charts'),
                  isDesktop: isDesktop,
                  onTap: () => context.push('/charts'),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.assignment_outlined,
                  label: 'Onboarding',
                  isActive: currentRoute == '/form',
                  isDesktop: isDesktop,
                  onTap: () => context.push('/form'),
                ),
              ],
            ),
          ),

          // Bottom API Status Box
          if (isDesktop)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF130F2B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2B2556)),
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
                      const SizedBox(width: 6),
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
                        ? 'Session verified for $userRole.'
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
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDesktop,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDesktop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 12 : 0,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2C2654) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment:
              isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF8E88AB),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFFCBD5E1),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}