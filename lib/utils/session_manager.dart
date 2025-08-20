// lib/utils/session_manager.dart
import 'dart:convert';
import 'package:app_laundry/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userKey = 'user';
  static const String _tokenKey = 'token';

  // Kanggo nyimpen sési
  static Future<void> saveSession(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = json.encode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role,
      'profile_photo_url': user.profilePhotoUrl,
    });
    await prefs.setString(_userKey, userJson);
    await prefs.setString(_tokenKey, token);
  }

  // Kanggo nyandak sési
  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    final token = prefs.getString(_tokenKey);

    if (userJson != null && token != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return {'user': User.fromJson(userMap), 'token': token};
    }
    return null;
  }

  // Kanggo ngahapus sési (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }
}
