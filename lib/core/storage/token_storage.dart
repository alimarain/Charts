import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyToken = 'vibeflow_jwt_token';
  static const String _keyRole = 'vibeflow_user_role';
  static const String _keyEmail = 'vibeflow_user_email';
  static const String _keyName = 'vibeflow_user_name';
  static const String _keyUserId = 'vibeflow_user_id';

  Future<void> saveSession({
    required String token,
    required String userId,
    required String email,
    required String name,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyRole, role);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);
    await prefs.remove(_keyRole);
  }
}
