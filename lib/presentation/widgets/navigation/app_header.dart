import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/controllers/dashboard_provider.dart';

import '../../controllers/auth_provider.dart';

class AppHeader extends ConsumerStatefulWidget {
  const AppHeader({
    super.key,
    this.title,
    this.showMenuButton = false,
    this.onMenuTap,
    this.actions = const [],
  });

  final String? title;
  final bool showMenuButton;
  final VoidCallback? onMenuTap;
  final List<Widget> actions;

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _hasSearchFocus = false;

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      _removeOverlay();
      return;
    }
    _showOrUpdateOverlay(query.trim().toLowerCase());
  }

  void _showOrUpdateOverlay(String query) {
    _removeOverlay();

    final products = ref.read(dashboardProvider).products;
    final matchedProducts = products
        .where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query);
        })
        .take(4)
        .toList();

    final List<_QuickSearchResult> quickResults = [
      if ('analytics'.contains(query) ||
          'charts'.contains(query) ||
          'telemetry'.contains(query) ||
          'revenue'.contains(query))
        const _QuickSearchResult(
          title: 'Performance Analytics & Telemetry',
          subtitle: 'Cartesian and Circular live data streams',
          icon: Icons.insights_rounded,
          route: '/charts',
        ),
      if ('form'.contains(query) ||
          'onboarding'.contains(query) ||
          'career'.contains(query) ||
          'kyc'.contains(query))
        const _QuickSearchResult(
          title: 'Resource Onboarding Form',
          subtitle: '2-step session data submission workflow',
          icon: Icons.assignment_outlined,
          route: '/form',
        ),
      if ('settings'.contains(query) ||
          'security'.contains(query) ||
          'saml'.contains(query) ||
          'profile'.contains(query))
        const _QuickSearchResult(
          title: 'System Configuration & Settings',
          subtitle: 'Security keys, user preferences, and audit logs',
          icon: Icons.settings_outlined,
          route: '/settings',
        ),
      if ('dashboard'.contains(query) ||
          'ledger'.contains(query) ||
          'catalog'.contains(query))
        const _QuickSearchResult(
          title: 'Resource Ledger & Catalog',
          subtitle: 'Active product allocations and live inventory',
          icon: Icons.storefront_rounded,
          route: '/dashboard',
        ),
    ];

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 340,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 42),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 340),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    if (matchedProducts.isEmpty && quickResults.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No matching resources or screens found.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    if (quickResults.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        child: Text(
                          'SYSTEM MODULES',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF9CA3AF),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      ...quickResults.map(
                        (res) => ListTile(
                          dense: true,
                          leading: Icon(
                            res.icon,
                            size: 16,
                            color: const Color(0xFF4F46E5),
                          ),
                          title: Text(
                            res.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          subtitle: Text(
                            res.subtitle,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          onTap: () {
                            _removeOverlay();
                            _searchController.clear();
                            context.push(res.route);
                          },
                        ),
                      ),
                    ],
                    if (matchedProducts.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        child: Text(
                          'MATCHED CATALOG ITEMS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF9CA3AF),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      ...matchedProducts.map(
                        (p) => ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: Color(0xFF059669),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          subtitle: Text(
                            '${p.category} · PKR ${(p.price * 280).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          onTap: () {
                            _removeOverlay();
                            _searchController.clear();
                            context.push('/dashboard/product/${p.id}');
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userName = user?.name ?? 'Marcus Vance';
    final userRole = user?.role == 'maker' ? 'Maker' : 'User';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;

          return Row(
            children: [
              if (widget.showMenuButton) ...[
                IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Color(0xFF1B1638),
                  ),
                  onPressed: widget.onMenuTap,
                ),
                const SizedBox(width: 4),
              ],

              if (widget.title != null && !isNarrow) ...[
                Text(
                  widget.title!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 14),
              ],

              // Universal Search Bar with Live Overlay
              Expanded(
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _hasSearchFocus
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            onTap: () => setState(() => _hasSearchFocus = true),
                            onEditingComplete: () {
                              setState(() => _hasSearchFocus = false);
                              _removeOverlay();
                            },
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              hintText:
                                  'Search resources, products, analytics...',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _removeOverlay();
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Page Custom Action Hooks (e.g. Export Menus)
              ...widget.actions,
              if (widget.actions.isNotEmpty) const SizedBox(width: 8),

              // Role Badge
              if (!isNarrow) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    '$userRole Access'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF374151),
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // User Profile Avatar & Sign Out
              InkWell(
                onTap: () => ref.read(authProvider.notifier).logout(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF1B1638),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!isNarrow) ...[
                        const SizedBox(width: 6),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.logout_rounded,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickSearchResult {
  const _QuickSearchResult({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}
