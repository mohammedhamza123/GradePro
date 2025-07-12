import 'dart:convert';
import 'package:gradpro/models/new_token.dart';
import 'package:gradpro/models/refreshed_token.dart';
import 'package:gradpro/services/endpoints.dart';
import 'package:gradpro/services/internet_services.dart';
import 'package:gradpro/services/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Login Service - Compatible with login_page.dart and user_provider.dart
/// 
/// This service provides:
/// - Core authentication with username/password
/// - Student approval system for numeric usernames
/// - Token management (access and refresh tokens)
/// - Session persistence using SharedPreferences
/// - Custom exceptions for pending approval and network timeouts
/// - Arabic error messages for better UX
/// - Backward compatibility with existing code
/// 
/// Integration:
/// - login_page.dart: Uses login() function and handles PendingApprovalException
/// - user_provider.dart: Uses login() and refreshLoginService() functions
/// - PendingApprovalException includes studentData for UI display

// Custom exception for pending approval students
class PendingApprovalException implements Exception {
  final String message;
  final Map<String, dynamic>? studentData;
  
  PendingApprovalException(this.message, [this.studentData]);
  
  @override
  String toString() => message;
}

// Custom exception for network timeouts
class NetworkTimeoutException implements Exception {
  final String message;
  NetworkTimeoutException(this.message);
  
  @override
  String toString() => message;
}

class LoginService {
  static const String _studentApprovalEndpoint = '/api/student-approval'; // Relative endpoint using base URL
  static const int _studentGroupId = 2;
  
  final InternetService _internetService = InternetService();

  /// Core login function with student approval system
  Future<bool> login(String username, String password) async {
    try {
      // Check if user is already authorized
      if (_internetService.isAuthorized()) {
        return true;
      }

      // Validate input parameters
      if (username.isEmpty || password.isEmpty) {
        throw Exception('اسم المستخدم وكلمة المرور مطلوبان');
      }

      // Check if this is a student login (numeric username)
      bool isStudent = _isStudentUsername(username);
      
      if (isStudent) {
        // Pre-login approval check for students
        bool isApproved = await _checkStudentApproval(username);
        if (!isApproved) {
          // Get student data for the exception
          Map<String, dynamic>? studentData = await _getStudentData(username);
          throw PendingApprovalException(
            'حسابك قيد المراجعة. يرجى الانتظار حتى يتم الموافقة عليه.',
            studentData
          );
        }
      }

      // Attempt login
      final tokenBody = await _internetService.post(
        CREATETOKEN, 
        {"username": username, "password": password}
      );

      // Debug logging
      print('DEBUG: Login response status: ${tokenBody.statusCode}');
      print('DEBUG: Login response body: ${tokenBody.body}');

      // Check both status code and response body
      if (tokenBody.statusCode != 200) {
        throw Exception('فشل في تسجيل الدخول. يرجى التحقق من بياناتك.');
      }

      // Parse response body to check for error messages
      try {
        final responseData = json.decode(tokenBody.body);
        
        // Check if response contains error message
        if (responseData.containsKey('detail') || 
            responseData.containsKey('error') || 
            responseData.containsKey('message')) {
          String errorMessage = responseData['detail'] ?? 
                               responseData['error'] ?? 
                               responseData['message'] ?? 
                               'اسم المستخدم أو كلمة المرور غير صحيحة';
          throw Exception(errorMessage);
        }
        
        // Check if response contains required token fields
        if (!responseData.containsKey('access') || !responseData.containsKey('refresh')) {
          throw Exception('استجابة غير صحيحة من الخادم');
        }
        
      } catch (e) {
        if (e is FormatException) {
          throw Exception('استجابة غير صحيحة من الخادم');
        }
        rethrow; // Re-throw if it's already an Exception
      }

      // Parse token response - NewToken contains both access and refresh tokens
      final token = newTokenFromJson(tokenBody.body);
      
      // Store tokens using TokenManager
      await TokenManager.saveTokens(
        accessToken: token.access,
        refreshToken: token.refresh,
        username: username,
      );
      
      // انتظار قليل للتأكد من حفظ التوكن
      await Future.delayed(const Duration(milliseconds: 300));
      
      _internetService.setToken(token.access);

      // Post-login approval verification for students
      if (isStudent) {
        bool isStillApproved = await _checkStudentApproval(username);
        if (!isStillApproved) {
          await logout(); // Clean up tokens
          // Get student data for the exception
          Map<String, dynamic>? studentData = await _getStudentData(username);
          throw PendingApprovalException(
            'تم رفض حسابك. يرجى التواصل مع الإدارة.',
            studentData
          );
        }
      }

      return true;
    } on PendingApprovalException {
      rethrow;
    } on NetworkTimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('خطأ في الشبكة. يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  /// Refresh login session using stored refresh token
  Future<bool> refreshLoginService() async {
    try {
      // تحميل التوكن من SharedPreferences أولاً
      await _internetService.loadTokenFromPrefs();
      
      // انتظار قليل للتأكد من تحميل التوكن
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (_internetService.isAuthorized()) {
        return true;
      }

      final String? storedToken = await TokenManager.getRefreshToken();
      if (storedToken == null || storedToken.isEmpty) {
        return false;
      }

      // Add timeout to prevent hanging
      final tokenResponse = await _internetService.post(
        REFRESHTOKEN, 
        {"refresh": storedToken}
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Token refresh timeout');
        },
      );

      if (tokenResponse.statusCode != 200) {
        await _clearTokens();
        return false;
      }

      // Parse refreshed token - RefreshedToken only contains new access token
      final refreshedToken = refreshedTokenFromJson(tokenResponse.body);
      _internetService.setToken(refreshedToken.access);
      
      // حفظ التوكن الجديد باستخدام TokenManager
      await TokenManager.saveAccessToken(refreshedToken.access);
      
      // انتظار قليل للتأكد من حفظ التوكن
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Note: RefreshedToken only contains access token, not refresh token
      // The original refresh token remains valid and stored for future refreshes

      return true;
    } catch (e) {
      await _clearTokens();
      return false;
    }
  }

  /// Complete logout with token cleanup
  Future<void> logout() async {
    try {
      // مسح التوكن من InternetService
      _internetService.removeToken();
      
      // انتظار قليل للتأكد من مسح التوكن
      await Future.delayed(const Duration(milliseconds: 100));
      
      // مسح جميع البيانات المحفوظة باستخدام TokenManager
      await TokenManager.clearAllTokens();
    } catch (e) {
      // Ensure tokens are cleared even if there's an error
      _internetService.removeToken();
      await TokenManager.clearAllTokens();
    }
  }

  /// Check if username represents a student (numeric)
  bool _isStudentUsername(String username) {
    return RegExp(r'^\d+$').hasMatch(username);
  }

  /// Check student approval status from external API
  Future<bool> _checkStudentApproval(String studentId) async {
    try {
      final response = await _internetService.get(
        '$_studentApprovalEndpoint/$studentId',
        null,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['approved'] == true && data['active'] == true;
      }
      
      return false;
    } catch (e) {
      // If approval service is unavailable, allow login but log the issue
      return true; // Allow login if approval service is down
    }
  }

  /// Get user details and group information
  Future<Map<String, dynamic>?> _getUserDetails(String username) async {
    try {
      final response = await _internetService.get('${USER}/$username', null);
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return userData;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get student data for pending approval
  Future<Map<String, dynamic>?> _getStudentData(String studentId) async {
    try {
      // Try to get student data from the approval endpoint
      final response = await _internetService.get(
        '$_studentApprovalEndpoint/$studentId',
        null,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'email': data['email'] ?? '',
          'first_name': data['first_name'] ?? '',
          'last_name': data['last_name'] ?? '',
          'serial_number': data['serial_number'] ?? studentId,
        };
      }
      
      // Fallback: return basic student data
      return {
        'email': '',
        'first_name': '',
        'last_name': '',
        'serial_number': studentId,
      };
    } catch (e) {
      // Return basic student data as fallback
      return {
        'email': '',
        'first_name': '',
        'last_name': '',
        'serial_number': studentId,
      };
    }
  }

  /// Store refresh token securely
  Future<void> _storeRefreshToken(String refreshToken) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("refresh", refreshToken);
    } catch (e) {
      throw Exception('فشل في حفظ بيانات الجلسة.');
    }
  }

  /// Retrieve stored refresh token
  Future<String?> _getRefreshToken() async {
    try {
      final token = await TokenManager.getRefreshToken();
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Clear all stored tokens
  Future<void> _clearTokens() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("refresh");
    } catch (e) {
    }
  }

  /// Check if user is currently authorized
  bool isAuthorized() {
    return _internetService.isAuthorized();
  }

  /// Get current access token
  String? getCurrentToken() {
    return _internetService.getToken();
  }

  /// Validate token format
  bool _isValidToken(String token) {
    return token.isNotEmpty && token.length > 10;
  }

  /// Force token refresh (for testing or manual refresh)
  Future<bool> forceTokenRefresh() async {
    try {
      await _clearTokens();
      return await refreshLoginService();
    } catch (e) {
      return false;
    }
  }
}

// Global instance for easy access
final LoginService loginService = LoginService();

// Legacy functions for backward compatibility
Future<bool> login(String username, String password) async {
  return await loginService.login(username, password);
}

Future<bool> refreshLoginService() async {
  return await loginService.refreshLoginService();
}

Future<void> logout() async {
  await loginService.logout();
}
