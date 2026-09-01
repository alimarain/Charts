import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  static const int port = 5238; // Default ASP.NET Core HTTP development port

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$port/api';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 connects Android Virtual Device to localhost
      return 'http://10.0.2.2:$port/api';
    }
    // Windows, macOS, Linux, iOS Simulator
    return 'http://localhost:$port/api';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
