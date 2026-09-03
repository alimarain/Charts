import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/datasources/product/api_product_service.dart';
import '../../domain/entities/product.dart';

/// Provider for the Product API Service instance
final productServiceProvider = Provider<ApiProductService>((ref) {
  return ApiProductService(ref.watch(dioProvider));
});

/// FutureProvider that fetches and caches the list of products for the catalog
final productsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(productServiceProvider).getProducts();
});

/// FutureProvider family that fetches single product details by ID
final productDetailsProvider = FutureProvider.family<Product, String>((
  ref,
  id,
) async {
  return ref.watch(productServiceProvider).getProductById(id);
});
