import 'dart:convert';

class JwtUtils {
  JwtUtils._();

  /// Generates a non-cryptographic mock JWT: base64(header).base64(payload).signature
  static String generateMockToken({
    required String userId,
    required String email,
    required String role,
  }) {
    final header = {'alg': 'HS256', 'typ': 'JWT'};

    final payload = {
      'sub': userId,
      'email': email,
      'role': role,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp':
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000,
    };

    final encodedHeader = _base64UrlEncode(jsonEncode(header));
    final encodedPayload = _base64UrlEncode(jsonEncode(payload));
    const mockSignature = 'mock_signature_for_learning_only';

    return '$encodedHeader.$encodedPayload.$mockSignature';
  }

  static String _base64UrlEncode(String input) {
    return base64Url.encode(utf8.encode(input)).replaceAll('=', '');
  }
}
