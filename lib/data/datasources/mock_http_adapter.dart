import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

/// Simulates a remote HTTP server inside Dio without making actual network calls.
class MockHttpAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Simulate real network roundtrip latency
    await Future.delayed(const Duration(milliseconds: 600));

    final path = options.path;
    final method = options.method.toUpperCase();

    // 1. GET /products
    if (path.endsWith('/products') && method == 'GET') {
      final mockData = [
        {
          'id': 'p1',
          'name': 'Classic Hoodie',
          'category': 'Apparel',
          'price': 49.99,
          'imageUrl': 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2',
          'description': 'Heavyweight fleece hooded sweatshirt for daily comfort.'
        },
        {
          'id': 'p2',
          'name': 'Oversized T-Shirt',
          'category': 'Apparel',
          'price': 24.99,
          'imageUrl': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518',
          'description': 'Relaxed drop-shoulder fit made from 100% organic cotton.'
        },
        {
          'id': 'p3',
          'name': 'Denim Jacket',
          'category': 'Outerwear',
          'price': 89.99,
          'imageUrl': 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0',
          'description': 'Vintage washed denim jacket with metal button closures.'
        },
        {
          'id': 'p4',
          'name': 'Cargo Pants',
          'category': 'Bottoms',
          'price': 59.99,
          'imageUrl': 'https://images.unsplash.com/photo-1517445312882-bc9910d016b7',
          'description': 'Utility trousers with multi-pocket storage and taper fit.'
        },
        {
          'id': 'p5',
          'name': 'Running Sneakers',
          'category': 'Footwear',
          'price': 119.99,
          'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
          'description': 'Lightweight responsive foam runners with breathable mesh.'
        },
        {
          'id': 'p6',
          'name': 'Casual Shirt',
          'category': 'Apparel',
          'price': 39.99,
          'imageUrl': 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c',
          'description': 'Breathable button-down shirt ideal for casual outings.'
        },
        {
          'id': 'p7',
          'name': 'Cotton Joggers',
          'category': 'Bottoms',
          'price': 44.99,
          'imageUrl': 'https://images.unsplash.com/photo-1552902865-b72c031ac5ea',
          'description': 'Slim tapered athletic pants with elasticized cuffs.'
        },
        {
          'id': 'p8',
          'name': 'Summer Dress',
          'category': 'Apparel',
          'price': 64.99,
          'imageUrl': 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446',
          'description': 'Lightweight floral dress crafted for warm climates.'
        },
      ];

      return ResponseBody.fromString(
        jsonEncode(mockData),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    // 2. POST /submit-form
    if (path.endsWith('/submit-form') && method == 'POST') {
      Map<String, dynamic> requestBody = {};

      try {
        if (options.data is List<int>) {
          requestBody = jsonDecode(utf8.decode(options.data as List<int>)) as Map<String, dynamic>;
        } else if (options.data is String) {
          requestBody = jsonDecode(options.data as String) as Map<String, dynamic>;
        } else if (options.data is Map) {
          requestBody = Map<String, dynamic>.from(options.data as Map);
        } else if (options.data is FormData) {
          final formData = options.data as FormData;
          requestBody = {
            for (final field in formData.fields) field.key: field.value,
          };
        }
      } catch (_) {
        requestBody = {};
      }

      final basicInfo = requestBody['basic_information'] as Map<String, dynamic>?;
      final fullName = basicInfo?['fullName'] ?? requestBody['fullName'];

      // Simulated failure condition
      if (fullName == 'Trigger Error') {
        return ResponseBody.fromString(
          jsonEncode({
            'status': 'error',
            'code': 'VALIDATION_FAILED',
            'error': 'Simulated submission rejection from server',
          }),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }

      // Simulated success response
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return ResponseBody.fromString(
        jsonEncode({
          'status': 'success',
          'submissionId': 'SUB_$timestamp',
          'message': 'Form successfully processed by mock server',
          'timestamp': timestamp,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    // 3. GET /simulate-error
    if (path.endsWith('/simulate-error')) {
      return ResponseBody.fromString(
        jsonEncode({'error': 'Resource not found'}),
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    // Fallback: 404 Not Found
    return ResponseBody.fromString(
      jsonEncode({'error': 'Endpoint not configured'}),
      404,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}