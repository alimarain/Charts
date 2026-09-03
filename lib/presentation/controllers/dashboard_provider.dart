import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/data/models/product_model.dart';

import 'product_provider.dart';
import 'dashboard_state.dart';

// Non-autoDispose notifier preserves state across navigation pushes and pops
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  () {
    return DashboardNotifier();
  },
);

class DashboardNotifier extends Notifier<DashboardState> {
  StreamSubscription<dynamic>? _subscription;

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
        final productModels = items
            .map(
              (p) => ProductModel(
                id: p.id,
                name: p.name,
                description: p.description,
                imageUrl: p.imageUrl,
                category: p.category,
                price: p.price,
              ),
            )
            .toList();

        state = state.copyWith(
          status: DashboardStatus.ready,
          products: productModels,
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
