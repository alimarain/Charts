import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/app/app_theme.dart';
import 'package:new_app/presentation/views/controllers/auth_provider.dart';
import 'package:new_app/presentation/views/controllers/dashboard_provider.dart';
import '../../widgets/analytics_preview_card.dart';
import '../../widgets/product_card.dart';
import '../analytics/analytics_screen.dart';
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

    final featuredProducts = dashboardState.products.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person_rounded, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, ${authUser?.name ?? "Shopper"}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Discover something new today.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            tooltip: 'Onboarding Form',
            onPressed: () => context.pushNamed(FormScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1000
              ? 4
              : (constraints.maxWidth > 650 ? 3 : 2);

          return CustomScrollView(
            key: const PageStorageKey('main_dashboard_scroll_key'),
            controller: _scrollController,
            slivers: [
              // Search Input
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: notifier.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search hoodies, jackets, sneakers...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                notifier.updateSearchQuery('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // Horizontal Category Filter
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = dashboardState.selectedCategory == cat;

                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) notifier.selectCategory(cat);
                        },
                      );
                    },
                  ),
                ),
              ),

              // Featured Horizontal Carousel
              if (featuredProducts.isNotEmpty && dashboardState.searchQuery.isEmpty && dashboardState.selectedCategory == 'All') ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'FEATURED DROPS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.1),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final product = featuredProducts[index];
                        return SizedBox(
                          width: 140,
                          child: ProductCard(
                            product: product,
                            onTap: () {
                              context.pushNamed(
                                ProductDetailsScreen.routeName,
                                pathParameters: {'id': product.id},
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // Compact Analytics Hub Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: AnalyticsPreviewCard(
                    onTap: () => context.pushNamed(AnalyticsScreen.routeName),
                  ),
                ),
              ),

              // Catalog Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'RECOMMENDED FOR YOU',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.1),
                  ),
                ),
              ),

              // Responsive Product Grid
              if (dashboardState.isLoading && dashboardState.products.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('No products matching "${dashboardState.searchQuery}"'),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
                      },
                      childCount: filteredItems.length,
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