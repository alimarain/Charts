import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

// --- Mock Data Definitions ---

final List<Map<String, dynamic>> mockMakerProductsData = [
  {
    'id': 'prod-loan-01',
    'code': 'SME_TERM_LOAN',
    'name': 'SME Term Loan',
    'category': 'Commercial Lending',
    'status': 'ACTIVE',
  },
  {
    'id': 'prod-card-02',
    'code': 'CORP_CREDIT_CARD',
    'name': 'Corporate Credit Card',
    'category': 'Cards',
    'status': 'ACTIVE',
  },
];

final Map<String, List<Map<String, dynamic>>> mockMakerFormsData = {
  'prod-loan-01': [
    {
      'formId': 'form-sme-app',
      'title': 'SME Credit Underwriting Application',
      'version': '1.2.0',
      'requiredRole': 'MAKER',
    },
    {
      'formId': 'form-kyc-doc',
      'title': 'Business Entity KYC & UBO Verification',
      'version': '2.0.0',
      'requiredRole': 'MAKER',
    },
  ],
  'prod-card-02': [
    {
      'formId': 'form-corp-card',
      'title': 'Corporate Card Issuance Requisition',
      'version': '1.0.1',
      'requiredRole': 'MAKER',
    },
  ],
};

final Map<String, List<Map<String, dynamic>>> mockDynamicFieldsData = {
  'form-sme-app': [
    {
      'id': 'f-1',
      'key': 'businessName',
      'label': 'Registered Business Name',
      'type': 'text',
      'required': true,
      'placeholder': 'Enter legal entity name',
    },
    {
      'id': 'f-2',
      'key': 'loanAmountRequested',
      'label': 'Requested Loan Amount (USD)',
      'type': 'number',
      'required': true,
      'placeholder': 'e.g. 250000',
    },
    {
      'id': 'f-3',
      'key': 'loanTenureMonths',
      'label': 'Tenure (Months)',
      'type': 'select',
      'required': true,
      'options': [12, 24, 36, 48, 60],
    },
  ],
  'form-kyc-doc': [
    {
      'id': 'f-4',
      'key': 'taxIdentificationNumber',
      'label': 'Tax Identification Number (TIN/EIN)',
      'type': 'text',
      'required': true,
      'placeholder': 'XX-XXXXXXX',
    },
  ],
};

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
          'imageUrl':
              'https://images.unsplash.com/photo-1556905055-8f358a7a47b2',
          'description':
              'Heavyweight fleece hooded sweatshirt for daily comfort.',
        },
        {
          'id': 'p2',
          'name': 'Oversized T-Shirt',
          'category': 'Apparel',
          'price': 24.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1521572267360-ee0c2909d518',
          'description':
              'Relaxed drop-shoulder fit made from 100% organic cotton.',
        },
        {
          'id': 'p3',
          'name': 'Denim Jacket',
          'category': 'Outerwear',
          'price': 89.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1576995853123-5a10305d93c0',
          'description':
              'Vintage washed denim jacket with metal button closures.',
        },
        {
          'id': 'p4',
          'name': 'Cargo Pants',
          'category': 'Bottoms',
          'price': 59.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1517445312882-bc9910d016b7',
          'description':
              'Utility trousers with multi-pocket storage and taper fit.',
        },
        {
          'id': 'p5',
          'name': 'Running Sneakers',
          'category': 'Footwear',
          'price': 119.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
          'description':
              'Lightweight responsive foam runners with breathable mesh.',
        },
        {
          'id': 'p6',
          'name': 'Casual Shirt',
          'category': 'Apparel',
          'price': 39.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1596755094514-f87e34085b2c',
          'description':
              'Breathable button-down shirt ideal for casual outings.',
        },
        {
          'id': 'p7',
          'name': 'Cotton Joggers',
          'category': 'Bottoms',
          'price': 44.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1552902865-b72c031ac5ea',
          'description': 'Slim tapered athletic pants with elasticized cuffs.',
        },
        {
          'id': 'p8',
          'name': 'Summer Dress',
          'category': 'Apparel',
          'price': 64.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446',
          'description': 'Lightweight floral dress crafted for warm climates.',
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
          requestBody = jsonDecode(
            utf8.decode(options.data as List<int>),
          ) as Map<String, dynamic>;
        } else if (options.data is String) {
          requestBody =
              jsonDecode(options.data as String) as Map<String, dynamic>;
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

      final basicInfo =
          requestBody['basic_information'] as Map<String, dynamic>?;
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

    // 3. GET /maker/products
    if (path.endsWith('/maker/products') && method == 'GET') {
      return ResponseBody.fromString(
        jsonEncode({
          'success': true,
          'message': 'Maker catalog fetched successfully',
          'data': mockMakerProductsData,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    // 4. GET /maker/products/{productId}/forms
    final productFormsRegex = RegExp(r'/maker/products/([^/]+)/forms$');
    if (productFormsRegex.hasMatch(path) && method == 'GET') {
      final match = productFormsRegex.firstMatch(path);
      final productId = match?.group(1) ?? '';
      final forms = mockMakerFormsData[productId] ?? [];

      return ResponseBody.fromString(
        jsonEncode({'success': true, 'data': forms}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    // 5. GET /maker/forms/{formId}/fields
    final formFieldsRegex = RegExp(r'/maker/forms/([^/]+)/fields$');
    if (formFieldsRegex.hasMatch(path) && method == 'GET') {
      final match = formFieldsRegex.firstMatch(path);
      final formId = match?.group(1) ?? '';
      final fields =
          mockDynamicFieldsData[formId] ??
          [
            {
              "id": "gen-1",
              "key": "applicantComments",
              "label": "Additional Case Comments",
              "type": "text",
              "required": true,
              "placeholder": "Enter generic notes...",
            },
          ];

      return ResponseBody.fromString(
        jsonEncode({'success': true, 'data': fields}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    // 6. POST /maker/forms/{formId}/submit
    final submitRegex = RegExp(r'/maker/forms/([^/]+)/submit$');
    if (submitRegex.hasMatch(path) && method == 'POST') {
      final now = DateTime.now();
      return ResponseBody.fromString(
        jsonEncode({
          'success': true,
          'message': 'Application underwritten and assigned successfully',
          'data': {
            'applicationId': 'APP-MKR-${now.millisecondsSinceEpoch}',
            'referenceNumber': 'REF-${(now.millisecondsSinceEpoch % 1000000)}',
            'status': 'PENDING_CHECKER_REVIEW',
            'submittedAt': now.toIso8601String(),
          },
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    // 7. GET /simulate-error
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
