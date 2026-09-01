import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import '../../../domain/entities/product.dart';

class ApiProductService {
  final Dio _dio;
  ApiProductService(this._dio);

  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!.map((item) {
          final map = item as Map<String, dynamic>;
          return Product(
            id: map['id'] as String,
            name: map['name'] as String,
            description: map['description'] as String,
            imageUrl: (map['imageUrl'] ?? '') as String,
            category: map['category'] as String,
            price: (map['price'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load products.');
    }
  }

  Stream<List<Product>> watchProducts() async* {
    final list = await getProducts();
    yield list;
  }

  void simulateError() {
    throw Exception('Simulated test error.');
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final map = apiResponse.data!;
        return Product(
          id: map['id'] as String,
          name: map['name'] as String,
          description: map['description'] as String,
          imageUrl: (map['imageUrl'] ?? '') as String,
          category: map['category'] as String,
          price: (map['price'] as num?)?.toDouble() ?? 0.0,
        );
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Product not found.');
    }
  }
}