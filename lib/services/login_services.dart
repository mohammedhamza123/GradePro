import 'package:gradpro/models/new_token.dart';
import 'package:gradpro/services/endpoints.dart';
import 'package:gradpro/services/internet_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../models/refreshed_token.dart';

// Custom exception for pending approval
class PendingApprovalException implements Exception {
  final String message;
  final Map<String, dynamic>? studentData;
  
  PendingApprovalException(this.message, {this.studentData});
  
  @override
  String toString() => message;
}

// Add function to check student approval status
Future<Map<String, dynamic>> checkStudentApprovalStatus(String username) async {
  try {
    final response = await http.get(
      Uri.parse("https://easy0123.pythonanywhere.com/student/?user=$username"),
      headers: {
        "Content-Type": "application/json",
      },
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return {
          'exists': true,
          'approved': data[0]['is_approved'] ?? false,
          'student_data': data[0],
        };
      }
    } else if (response.statusCode == 403) {
      // Student exists but not approved
      return {
        'exists': true,
        'approved': false,
        'student_data': null,
      };
    }
    
    return {
      'exists': false,
      'approved': false,
      'student_data': null,
    };
  } on TimeoutException catch (_) {
    throw Exception("انتهت مهلة الاتصال بالسيرفر. تأكد من الشبكة وحاول مرة أخرى.");
  } catch (e) {
    return {
      'exists': false,
      'approved': false,
      'student_data': null,
    };
  }
}

Future<bool> login(String username, String password) async {
  final InternetService services = InternetService();
  if (services.isAuthorized()) {
    return true;
  } else {
    try {
      // Check if it's a student login attempt first
      if (int.tryParse(username) != null) {
        final approvalStatus = await checkStudentApprovalStatus(username);
        if (approvalStatus['exists'] && !approvalStatus['approved']) {
          // Student exists but not approved - throw specific exception
          throw PendingApprovalException(
            "حسابك قيد المراجعة من قبل الإدارة. يرجى الانتظار حتى يتم الموافقة على طلبك.",
            studentData: approvalStatus['student_data'],
          );
        }
      }
      
      // Make direct HTTP call for token creation (no authentication required)
      final url = Uri.parse("https://easy0123.pythonanywhere.com$CREATETOKEN");
      print("Attempting login to: $url");
      print("Username: $username");
      
      final tokenBody = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"username": username, "password": password}),
        encoding: Encoding.getByName("utf-8"),
      ).timeout(const Duration(seconds: 15));
      
      print("Response status: ${tokenBody.statusCode}");
      print("Response body: ${tokenBody.body}");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        final token = newTokenFromJson(tokenBody.body);
        await prefs.setString("refresh", token.refresh);
        services.setToken(token.access);
        
        // Check if user is a student and if they are approved
        try {
          final userResponse = await http.get(
            Uri.parse("https://easy0123.pythonanywhere.com$MYACCOUNT"),
            headers: {
              "Authorization": "Bearer ${token.access}",
              "Content-Type": "application/json",
            },
          ).timeout(const Duration(seconds: 10));
          
          if (userResponse.statusCode == 200) {
            final userData = jsonDecode(userResponse.body);
            if (userData.isNotEmpty && userData[0]['groups'] != null && userData[0]['groups'].isNotEmpty) {
              // Check if user is a student (group 2)
              if (userData[0]['groups'][0] == 2) {
                // Check if student is approved
                final studentResponse = await http.get(
                  Uri.parse("https://easy0123.pythonanywhere.com/student/?user=${userData[0]['id']}"),
                  headers: {
                    "Authorization": "Bearer ${token.access}",
                    "Content-Type": "application/json",
                  },
                ).timeout(const Duration(seconds: 10));
                
                if (studentResponse.statusCode == 403) {
                  // Student is not approved, remove token and throw exception
                  services.removeToken();
                  await prefs.remove("refresh");
                  throw PendingApprovalException(
                    "حسابك قيد المراجعة من قبل الإدارة. يرجى الانتظار حتى يتم الموافقة على طلبك.",
                  );
                }
              }
            }
          }
        } catch (e) {
          if (e is PendingApprovalException) {
            rethrow;
          }
          // If there's an error checking approval, assume it's not approved
          services.removeToken();
          await prefs.remove("refresh");
          return false;
        }
        
        return true;
      } catch (e) {
        print("Login error: $e");
        if (e is PendingApprovalException) {
          rethrow;
        }
        if (e is TimeoutException) {
          throw Exception("انتهت مهلة الاتصال بالسيرفر. تأكد من الشبكة وحاول مرة أخرى.");
        }
        // If token creation fails, check if it's a student with pending approval
        if (int.tryParse(username) != null) {
          // Likely a student login attempt
          final approvalStatus = await checkStudentApprovalStatus(username);
          if (approvalStatus['exists'] && !approvalStatus['approved']) {
            // Student exists but not approved
            throw PendingApprovalException(
              "حسابك قيد المراجعة من قبل الإدارة. يرجى الانتظار حتى يتم الموافقة على طلبك.",
              studentData: approvalStatus['student_data'],
            );
          }
        }
        throw Exception("فشل تسجيل الدخول. تأكد من اسم المستخدم وكلمة المرور.");
      }
    } catch (e) {
      print("Login error: $e");
      if (e is PendingApprovalException) {
        rethrow;
      }
      if (e is TimeoutException) {
        throw Exception("انتهت مهلة الاتصال بالسيرفر. تأكد من الشبكة وحاول مرة أخرى.");
      }
      throw Exception("فشل تسجيل الدخول. تأكد من اسم المستخدم وكلمة المرور.");
    }
  }
}

Future<bool> refreshLoginService() async {
  final InternetService services = InternetService();
  if (!services.isAuthorized()) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedToken = prefs.getString("refresh");
    if (storedToken == null || storedToken.isEmpty) {
      return false;
    }
    
    try {
      // Make direct HTTP call for token refresh (no authentication required)
      final url = Uri.parse("https://easy0123.pythonanywhere.com$REFRESHTOKEN");
      final token = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"refresh": storedToken}),
        encoding: Encoding.getByName("utf-8"),
      ).timeout(const Duration(seconds: 10));
      services.setToken(refreshedTokenFromJson(token.body).access);
      return true;
    } catch (e) {
      return false;
    }
  } else {
    return true;
  }
}

Future<void> logout() async {
  final InternetService services = InternetService();
  services.removeToken();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("refresh");
}
