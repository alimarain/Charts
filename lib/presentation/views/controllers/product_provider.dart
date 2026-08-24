import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/core/network/dio_client.dart';
import 'package:new_app/data/datasources/product/product_service.dart';


final productServiceProvider = Provider<ProductService>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductService(dio);
});