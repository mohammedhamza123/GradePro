import 'package:gradpro/services/token_manager.dart';

/// TokenTest - اختبار بسيط لنظام التوكن
/// 
/// هذا الملف يحتوي على وظائف اختبار بسيطة للتأكد من عمل نظام التوكن

class TokenTest {
  
  /// اختبار حفظ واسترجاع التوكن
  static Future<void> testTokenStorage() async {
    
    try {
      // اختبار حفظ التوكن
      await TokenManager.saveTokens(
        accessToken: 'test_access_token_123',
        refreshToken: 'test_refresh_token_456',
        username: 'test_user',
      );
      
      // اختبار استرجاع التوكن
      final accessToken = await TokenManager.getAccessToken();
      final refreshToken = await TokenManager.getRefreshToken();
      final username = await TokenManager.getSavedUsername();
      
      if (accessToken == 'test_access_token_123' &&
          refreshToken == 'test_refresh_token_456' &&
          username == 'test_user') {
      } else {
      }
      
      // اختبار التحقق من وجود التوكن
      final hasToken = await TokenManager.hasValidToken();
      if (hasToken) {
      } else {
      }
      
      // اختبار مسح التوكن
      await TokenManager.clearAllTokens();
      final hasTokenAfterClear = await TokenManager.hasValidToken();
      if (!hasTokenAfterClear) {
      } else {
      }
      
    } catch (e) {
    }
  }
  
  /// اختبار سيناريو تسجيل الدخول الكامل
  static Future<void> testLoginScenario() async {
    
    try {
      // محاكاة تسجيل الدخول
      await TokenManager.saveTokens(
        accessToken: 'real_access_token',
        refreshToken: 'real_refresh_token',
        username: 'real_user',
      );
      
      // محاكاة فتح التطبيق
      final hasToken = await TokenManager.hasValidToken();
      if (hasToken) {
      } else {
      }
      
      // محاكاة تسجيل الخروج
      await TokenManager.clearAllTokens();
      final hasTokenAfterLogout = await TokenManager.hasValidToken();
      if (!hasTokenAfterLogout) {
      } else {
      }
      
    } catch (e) {
    }
  }
  
  /// تشغيل جميع الاختبارات
  static Future<void> runAllTests() async {
    
    await testTokenStorage();
    
    await testLoginScenario();
    
  }
} 