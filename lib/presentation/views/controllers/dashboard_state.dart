import 'package:new_app/data/models/product_model.dart';


enum DashboardStatus {
  loading,
  ready,
  error,
}

class DashboardState {
  const DashboardState({
    this.status = DashboardStatus.loading,
    this.products = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.scrollOffset = 0.0,
    this.errorMessage,
  });

  final DashboardStatus status;
  final List<ProductModel> products;
  final String searchQuery;
  final String selectedCategory;
  final double scrollOffset;
  final String? errorMessage;

  bool get isLoading => status == DashboardStatus.loading;
  bool get isReady => status == DashboardStatus.ready;
  bool get isError => status == DashboardStatus.error;

  /// Pure computation for combined search query + category filtering
  List<ProductModel> get filteredProducts {
    return products.where((product) {
      final matchesCategory = selectedCategory == 'All' ||
          product.category.toLowerCase() == selectedCategory.toLowerCase();

      final cleanQuery = searchQuery.trim().toLowerCase();
      final matchesSearch = cleanQuery.isEmpty ||
          product.name.toLowerCase().contains(cleanQuery) ||
          product.category.toLowerCase().contains(cleanQuery) ||
          product.description.toLowerCase().contains(cleanQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  DashboardState copyWith({
    DashboardStatus? status,
    List<ProductModel>? products,
    String? searchQuery,
    String? selectedCategory,
    double? scrollOffset,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}