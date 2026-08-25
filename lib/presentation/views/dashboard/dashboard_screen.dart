import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/views/controllers/dashboard_provider.dart';

import '../../controllers/auth_provider.dart';
import '../../widgets/product_card.dart';
import '../form/form_screen.dart';
import 'product_details_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  static const routeName = 'dashboard';
  static const routePath = '/dashboard';

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  static const Color inkBg = Color(0xFF080511);
  static const Color glassBg = Color(0xFF17122B);
  static const Color lineBorder = Color(0xFF282045);
  static const Color tealAccent = Color(0xFF00F2FE);
  static const Color limeAccent = Color(0xFFC4F74B);
  static const Color purpleAccent = Color(0xFFA855F7);
  static const Color faintText = Color(0xFF827B9E);
  static const Color brightText = Color(0xFFECE8FF);

  static const List<String> _categories = [
    'All',
    'T-Shirts',
    'Hoodies',
    'Jackets',
    'Jeans',
    'Pants',
    'Sneakers',
    'Dresses',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    final currentSearch = ref.read(dashboardProvider).searchQuery;
    _searchController = TextEditingController(text: currentSearch);

    final initialOffset = ref.read(dashboardProvider).scrollOffset;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollPosition();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      ref
          .read(dashboardProvider.notifier)
          .updateScrollOffset(_scrollController.offset);
    }
  }

  void _restoreScrollPosition() {
    if (!_scrollController.hasClients) return;
    final targetOffset = ref.read(dashboardProvider).scrollOffset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final safeOffset = targetOffset.clamp(0.0, maxScroll);

    if (_scrollController.offset != safeOffset) {
      _scrollController.jumpTo(safeOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);
    final authUser = ref.watch(authProvider).user;
    final filteredItems = dashboardState.filteredProducts;

    if (_searchController.text != dashboardState.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: dashboardState.searchQuery,
        selection: TextSelection.collapsed(
          offset: dashboardState.searchQuery.length,
        ),
      );
    }

    return Scaffold(
      backgroundColor: inkBg,
      appBar: AppBar(
        backgroundColor: inkBg,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [tealAccent, Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: tealAccent.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: inkBg,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'STORE CATALOG',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: brightText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Browse Products · ${authUser?.name ?? "Member"}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: faintText,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.assignment_outlined,
              color: faintText,
              size: 20,
            ),
            tooltip: 'Onboarding Form',
            onPressed: () => context.pushNamed(FormScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: faintText, size: 20),
            tooltip: 'Sign Out',
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1100
              ? 4
              : (constraints.maxWidth > 700 ? 3 : 2);

          return CustomScrollView(
            key: const PageStorageKey('main_store_dashboard_key'),
            controller: _scrollController,
            slivers: [
              // Search Input Box
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: glassBg.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: lineBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: notifier.updateSearchQuery,
                      style: const TextStyle(color: brightText, fontSize: 13),
                      decoration: InputDecoration(
                        filled: false,
                        hintText: 'Search clothing, sneakers, jackets...',
                        hintStyle: const TextStyle(
                          color: faintText,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: faintText,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 18,
                                  color: faintText,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  notifier.updateSearchQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Horizontal Category Filter Chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = dashboardState.selectedCategory == cat;

                      return GestureDetector(
                        onTap: () => notifier.selectCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? tealAccent.withValues(alpha: 0.15)
                                : glassBg.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? tealAccent : lineBorder,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected ? tealAccent : faintText,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Summary Metric Banner (Products & Category count only, no chart widgets)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: glassBg.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: lineBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                'Store Inventory',
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: brightText,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: limeAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: limeAccent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Text(
                                'ACTIVE STREAM',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: limeAccent,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Showing active items from our store catalog stream.',
                          style: TextStyle(fontSize: 12, color: faintText),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricBadge(
                                icon: Icons.checkroom_rounded,
                                iconColor: tealAccent,
                                value: '${dashboardState.products.length}',
                                label: 'Total Products',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricBadge(
                                icon: Icons.filter_alt_rounded,
                                iconColor: purpleAccent,
                                value: dashboardState.selectedCategory,
                                label: 'Selected Category',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Catalog Header Title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'CURATED ITEMS & ARTIFACTS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: faintText,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Product Grid / Loading / Empty State
              if (dashboardState.isLoading && dashboardState.products.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: tealAccent,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              else if (filteredItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: faintText,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No items matching "${dashboardState.searchQuery}"',
                          style: const TextStyle(
                            color: faintText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = filteredItems[index];
                      return ProductCard(
                        product: item,
                        onTap: () {
                          context.pushNamed(
                            ProductDetailsScreen.routeName,
                            pathParameters: {'id': item.id},
                          );
                        },
                      );
                    }, childCount: filteredItems.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF100D1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF282045)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFECE8FF),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF827B9E),
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
