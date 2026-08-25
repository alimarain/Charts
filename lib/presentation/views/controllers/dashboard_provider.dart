import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_state.dart';
import 'product_provider.dart';

// Non-autoDispose notifier preserves state across navigation pushes and pops
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  () {
    return DashboardNotifier();
  },
);

class DashboardNotifier extends Notifier<DashboardState> {
  StreamSubscription<List<dynamic>>? _subscription;

  @override
  DashboardState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    // Start stream listening on next event tick so initial state build completes first
    Future.microtask(() => _listenToProductStream());

    return const DashboardState(status: DashboardStatus.loading);
  }

  void _listenToProductStream() {
    _subscription?.cancel();

    // Only set loading if there are no existing products to prevent layout jumps on navigation
    if (state.products.isEmpty) {
      state = state.copyWith(status: DashboardStatus.loading, clearError: true);
    }

    final productService = ref.read(productServiceProvider);

    _subscription = productService.watchProducts().listen(
      (items) {
        state = state.copyWith(
          status: DashboardStatus.ready,
          products: items,
          clearError: true,
        );
      },
      onError: (dynamic err) {
        state = state.copyWith(
          status: DashboardStatus.error,
          errorMessage: 'Failed to stream live catalog: $err',
        );
      },
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void updateScrollOffset(double offset) {
    state = state.copyWith(scrollOffset: offset);
  }

  void retry() {
    _listenToProductStream();
  }
}
