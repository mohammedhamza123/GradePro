import 'package:gradpro/services/token_manager.dart';

/// TokenTest - اختبار بسيط لنظام التوكن
/// 
/// هذا الملف يحتوي على وظائف اختبار بسيطة للتأكد من عمل نظام التوكن

class TokenTest {
  
  /// اختبار حفظ واسترجاع التوكن
  static Future<void> testTokenStorage() async {
    print('🧪 Testing token storage...');
    
    try {
      // اختبار حفظ التوكن
      await TokenManager.saveTokens(
        accessToken: 'test_access_token_123',
        refreshToken: 'test_refresh_token_456',
        username: 'test_user',
      );
      print('✅ Tokens saved successfully');
      
      // اختبار استرجاع التوكن
      final accessToken = await TokenManager.getAccessToken();
      final refreshToken = await TokenManager.getRefreshToken();
      final username = await TokenManager.getSavedUsername();
      
      if (accessToken == 'test_access_token_123' &&
          refreshToken == 'test_refresh_token_456' &&
          username == 'test_user') {
        print('✅ Tokens retrieved successfully');
      } else {
        print('❌ Token retrieval failed');
      }
      
      // اختبار التحقق من وجود التوكن
      final hasToken = await TokenManager.hasValidToken();
      if (hasToken) {
        print('✅ Token validation successful');
      } else {
        print('❌ Token validation failed');
      }
      
      // اختبار مسح التوكن
      await TokenManager.clearAllTokens();
      final hasTokenAfterClear = await TokenManager.hasValidToken();
      if (!hasTokenAfterClear) {
        print('✅ Token clearing successful');
      } else {
        print('❌ Token clearing failed');
      }
      
    } catch (e) {
      print('❌ Test failed with error: $e');
    }
  }
  
  /// اختبار سيناريو تسجيل الدخول الكامل
  static Future<void> testLoginScenario() async {
    print('🧪 Testing complete login scenario...');
    
    try {
      // محاكاة تسجيل الدخول
      await TokenManager.saveTokens(
        accessToken: 'real_access_token',
        refreshToken: 'real_refresh_token',
        username: 'real_user',
      );
      print('✅ Login simulation successful');
      
      // محاكاة فتح التطبيق
      final hasToken = await TokenManager.hasValidToken();
      if (hasToken) {
        print('✅ Auto-login check successful');
      } else {
        print('❌ Auto-login check failed');
      }
      
      // محاكاة تسجيل الخروج
      await TokenManager.clearAllTokens();
      final hasTokenAfterLogout = await TokenManager.hasValidToken();
      if (!hasTokenAfterLogout) {
        print('✅ Logout simulation successful');
      } else {
        print('❌ Logout simulation failed');
      }
      
    } catch (e) {
      print('❌ Login scenario test failed: $e');
    }
  }
  
  /// تشغيل جميع الاختبارات
  static Future<void> runAllTests() async {
    print('🚀 Starting token system tests...\n');
    
    await testTokenStorage();
    print('');
    
    await testLoginScenario();
    print('');
    
    print('🏁 All tests completed!');
  }
} 