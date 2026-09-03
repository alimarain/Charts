import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/controllers/dashboard_provider.dart';

import '../../controllers/auth_provider.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/dashboard/dashboard_ledger_table.dart';
import '../../widgets/navigation/app_header.dart';
import '../../widgets/navigation/app_sidebar.dart';
import '../form/form_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  static const routeName = 'dashboard';
  static const routePath = '/dashboard';

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  static const List<String> _categories = [
    'All',
    'Finance',
    'Vehicle',
    'Real Estate',
    'T-Shirts',
    'Hoodies',
    'Jackets',
    'Jeans',
    'Pants',
    'Sneakers',
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
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role == 'maker' ? 'Maker' : 'User';
    final hasToken = authState.token != null && authState.token!.isNotEmpty;
    final filteredItems = dashboardState.filteredProducts;

    if (_searchController.text != dashboardState.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: dashboardState.searchQuery,
        selection: TextSelection.collapsed(
          offset: dashboardState.searchQuery.length,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8F9FC),
          drawer: isDesktop
              ? null
              : Drawer(
                  child: AppSidebar(
                    currentRoute: '/dashboard',
                    hasToken: hasToken,
                    userRole: userRole,
                    isMobileDrawer: true,
                  ),
                ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDesktop)
                AppSidebar(
                  currentRoute: '/dashboard',
                  hasToken: hasToken,
                  userRole: userRole,
                ),
              Expanded(
                child: Column(
                  children: [
                    AppHeader(
                      title: 'Resource Ledger',
                      showMenuButton: !isDesktop,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B1638),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () =>
                              context.pushNamed(FormScreen.routeName),
                          child: const Text(
                            'New Resource',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (dashboardState.isLoading &&
                              dashboardState.products.isEmpty) {
                            return const AppLoadingView();
                          }

                          if (dashboardState.isError &&
                              dashboardState.products.isEmpty) {
                            return AppErrorView(
                              message:
                                  'Could not load catalog: ${dashboardState.errorMessage}',
                              onRetry: () => notifier.retry(),
                            );
                          }

                          return SingleChildScrollView(
                            key: const PageStorageKey(
                              'main_dashboard_ledger_scroll_key',
                            ),
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 28.0 : 16.0,
                              vertical: 20.0,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1240,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DashboardLedgerTable(
                                      products: filteredItems,
                                      searchController: _searchController,
                                      selectedCategory:
                                          dashboardState.selectedCategory,
                                      categories: _categories,
                                      onSearchChanged:
                                          notifier.updateSearchQuery,
                                      onCategorySelected:
                                          notifier.selectCategory,
                                    ),
                                    const SizedBox(height: 28),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
