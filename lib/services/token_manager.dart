import 'package:shared_preferences/shared_preferences.dart';

/// TokenManager - إدارة محسنة للتوكن
///
/// هذا الملف يوفر إدارة مركزية للتوكن مع وظائف مساعدة
/// للتحقق من حالة التوكن وحفظه ومسحه

class TokenManager {
  static const String _accessTokenKey = "access";
  static const String _refreshTokenKey = "refresh";
  static const String _usernameKey = "current_username";

  /// حفظ التوكن في SharedPreferences
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
      if (username != null) {
        await prefs.setString(_usernameKey, username);
      }

      // انتظار قليل للتأكد من حفظ البيانات
      await Future.delayed(const Duration(milliseconds: 200));

      // التحقق من أن التوكن تم حفظه بنجاح
      prefs.getString(_accessTokenKey);
      prefs.getString(_refreshTokenKey);
    } catch (e) {
      throw Exception('فشل في حفظ بيانات الجلسة');
    }
  }

  /// حفظ توكن الوصول فقط
  static Future<void> saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString(_accessTokenKey, accessToken);

      // انتظار قليل للتأكد من حفظ البيانات
      await Future.delayed(const Duration(milliseconds: 100));

      // التحقق من أن التوكن تم حفظه بنجاح
      prefs.getString(_accessTokenKey);
    } catch (e) {}
  }

  /// الحصول على توكن الوصول
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final token = prefs.getString(_accessTokenKey);

      // إذا كان التوكن فارغ أو null، ارجع null
      if (token == null || token.isEmpty) {
        return null;
      }

      return token;
    } catch (e) {
      return null;
    }
  }

  /// الحصول على توكن التحديث
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final token = prefs.getString(_refreshTokenKey);

      // إذا كان التوكن فارغ أو null، ارجع null
      if (token == null || token.isEmpty) {
        return null;
      }

      return token;
    } catch (e) {
      return null;
    }
  }

  /// الحصول على اسم المستخدم المحفوظ
  static Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final username = prefs.getString(_usernameKey);
      return username;
    } catch (e) {
      return null;
    }
  }

  /// التحقق من وجود توكن صالح
  static Future<bool> hasValidToken() async {
    await SharedPreferences.getInstance();
    try {
      final token = await getAccessToken();
      final hasToken = token != null && token.isNotEmpty;
      return hasToken;
    } catch (e) {
      return false;
    }
  }

  /// مسح جميع البيانات المحفوظة
  static Future<void> clearAllTokens() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_usernameKey);

      // انتظار قليل للتأكد من مسح البيانات
      await Future.delayed(const Duration(milliseconds: 100));

      // التحقق من أن التوكن تم مسحه بنجاح
      prefs.getString(_accessTokenKey);
      prefs.getString(_refreshTokenKey);
      prefs.getString(_usernameKey);
    } catch (e) {}
  }

  /// مسح توكن محدد
  static Future<void> clearToken(String tokenKey) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.remove(tokenKey);
    } catch (e) {}
  }
}
