import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../domain/entities/maker_models.dart';
import '../../../domain/repositories/maker_repository.dart';

class MakerService implements MakerRepository {
  MakerService(this._dio);

  final Dio _dio;

  List<dynamic> _extractList(dynamic rawData) {
    dynamic decoded = rawData;
    if (decoded is String) {
      decoded = jsonDecode(decoded);
    }
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      final inner = decoded['data'];
      if (inner is List) return inner;
    }
    if (decoded is List) {
      return decoded;
    }
    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic rawData) {
    dynamic decoded = rawData;
    if (decoded is String) {
      decoded = jsonDecode(decoded);
    }
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('data') &&
          decoded['data'] is Map<String, dynamic>) {
        return decoded['data'] as Map<String, dynamic>;
      }
      return decoded;
    }
    return <String, dynamic>{};
  }

  @override
  Future<List<MakerProduct>> getMakerProducts() async {
    try {
      final response = await _dio.get('/maker/products');
      final list = _extractList(response.data);
      return list
          .map(
            (e) => MakerProduct.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Failed to parse maker products: $e');
    }
  }

  @override
  Future<List<MakerForm>> getMakerForms(String productId) async {
    try {
      final response = await _dio.get('/maker/products/$productId/forms');
      final list = _extractList(response.data);
      return list
          .map((e) => MakerForm.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Failed to parse maker forms: $e');
    }
  }

  @override
  Future<List<DynamicFormField>> getFormFields(String formId) async {
    try {
      final response = await _dio.get('/maker/forms/$formId/fields');
      final list = _extractList(response.data);
      return list
          .map(
            (e) =>
                DynamicFormField.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Failed to parse form fields: $e');
    }
  }

  @override
  Future<ApplicationSubmissionResponse> submitApplication({
    required String formId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final response = await _dio.post(
        '/maker/forms/$formId/submit',
        data: jsonEncode({'formId': formId, 'answers': answers}),
      );
      final map = _extractMap(response.data);
      return ApplicationSubmissionResponse.fromJson(map);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Failed to submit application: $e');
    }
  }
}
