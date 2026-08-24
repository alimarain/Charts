import 'dart:async';
import 'package:dio/dio.dart';
import '../../../core/errors/api_exception.dart';
import '../../models/product_model.dart';
import 'product_mock_data.dart';

class ProductService {
  ProductService(this._dio);

  final Dio _dio;

  /// Fetches a one-time product list via Dio (used in HomeScreen network testing)
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      final data = response.data as List<dynamic>;

      return data
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected parsing error: $e');
    }
  }

  /// Triggers a 404 test endpoint to verify Dio error conversion (used in HomeScreen)
  Future<void> simulateError() async {
    try {
      await _dio.get('/simulate-error');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Simulates a live product stream with periodic updates (used in Dashboard)
  Stream<List<ProductModel>> watchProducts() async* {
    List<ProductModel> currentProducts =
        List<ProductModel>.from(initialMockProducts);

    // Initial load delay
    await Future.delayed(const Duration(milliseconds: 600));
    yield currentProducts;

    var tick = 0;
    while (true) {
      await Future.delayed(const Duration(seconds: 8));
      tick++;

      if (tick % 2 == 1) {
        // Flash sale price shift simulation on p1 (Minimal Heavyweight Oversized Hoodie)
        currentProducts = currentProducts.map((p) {
          if (p.id == 'p1') {
            final newPrice = (p.price == 64.99) ? 49.99 : 64.99;
            return ProductModel(
              id: p.id,
              name: '${p.name} (Flash Sale!)',
              category: p.category,
              price: newPrice,
              imageUrl: p.imageUrl,
              description: p.description,
            );
          }
          return p;
        }).toList();
      } else {
        // Limited release drop simulation using studio-grade asset
        final dropId = 'drop_$tick';
        final newDrop = ProductModel(
          id: dropId,
          name: 'Limited Edition Technical Overshirt #$tick',
          category: 'Jackets',
          price: 98.00,
          imageUrl:
              'https://images.unsplash.com/photo-1544923246-77307dd654cb?auto=format&fit=crop&w=800&q=80',
          description:
              'Special seasonal live drop released straight to the storefront telemetry feed.',
        );

        if (!currentProducts.any((p) => p.id == dropId)) {
          currentProducts = [newDrop, ...currentProducts];
        }
      }

      yield currentProducts;
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    final products = initialMockProducts;
    return products.cast<ProductModel?>().firstWhere(
          (p) => p?.id == id,
          orElse: () => null,
        );
  }
}