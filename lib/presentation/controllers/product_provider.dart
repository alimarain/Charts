import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/datasources/product/api_product_service.dart';
import '../../domain/entities/product.dart';

final productServiceProvider = Provider<ApiProductService>((ref) {
  return ApiProductService(ref.watch(dioProvider));
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(productServiceProvider).getProducts();
});

final productDetailsProvider = FutureProvider.family<Product, String>((
  ref,
  id,
) async {
  return ref.watch(productServiceProvider).getProductById(id);
});
