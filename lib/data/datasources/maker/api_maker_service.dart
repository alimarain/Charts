import 'package:dio/dio.dart';
import 'package:new_app/domain/entities/maker_models.dart';
import '../../../core/network/api_response.dart';

class ApiMakerService {
  final Dio _dio;
  ApiMakerService(this._dio);

  Future<List<MakerProduct>> getMakerProducts() async {
    try {
      final response = await _dio.get('/maker/products');
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!.map((p) {
          final map = p as Map<String, dynamic>;
          return MakerProduct(
            id: map['id'] as String,
            name: map['name'] as String,
            description: map['description'] as String,
            iconName: (map['image'] ?? map['iconName'] ?? 'folder') as String,
            category: map['category'] as String,
            status: map['status'] as String,
            formCount: (map['formCount'] as num).toInt(),
          );
        }).toList();
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Unauthorized access. Maker role required.');
      }
      throw Exception(e.response?.data?['message'] ?? 'Failed to load Maker products.');
    }
  }

  Future<List<MakerForm>> getFormsByProduct(String productId) async {
    try {
      final response = await _dio.get('/maker/products/$productId/forms');
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!.map((f) {
          final map = f as Map<String, dynamic>;
          return MakerForm(
            id: map['id'] as String,
            productId: productId,
            title: (map['title'] ?? map['name'] ?? '') as String,
            description: map['description'] as String,
            fieldCount: (map['fieldCount'] as num).toInt(),
          );
        }).toList();
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load forms.');
    }
  }

  Future<List<DynamicFormField>> getFieldsByForm(String formId) async {
    try {
      final response = await _dio.get('/maker/forms/$formId/fields');
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!.map((field) {
          final map = field as Map<String, dynamic>;
          return DynamicFormField(
            id: map['id'] as String,
            label: map['label'] as String,
            key: map['key'] as String,
            type: map['type'] as String,
            required: map['required'] as bool,
            options: (map['options'] as List<dynamic>?)
                    ?.map((o) => o.toString())
                    .toList() ??
                [],
          );
        }).toList();
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load form fields.');
    }
  }

  Future<String> submitApplication(
    String formId,
    Map<String, dynamic> dynamicAnswers,
  ) async {
    try {
      final response = await _dio.post(
        '/maker/forms/$formId/submit',
        data: {'answers': dynamicAnswers},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!['applicationId'] as String;
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Application submission failed.');
    }
  }
}