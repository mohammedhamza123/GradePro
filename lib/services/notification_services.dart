import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'endpoints.dart';
import 'internet_services.dart';
import '../models/student_list.dart';
import '../models/project_list.dart';

class NotificationService {
  static const String _notificationKey = 'notifications';
  static const String _lastCheckKey = 'last_notification_check';
  static Timer? _pollingTimer;
  static Function(List<Map<String, dynamic>>)? _onNewNotifications;
  
  final InternetService _internetService = InternetService();
  
  // حفظ إشعار جديد
  static Future<void> saveNotification(String title, String message, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList(_notificationKey) ?? [];
    
    final notification = jsonEncode({
      'title': title,
      'message': message,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    });
    
    notifications.add(notification);
    await prefs.setStringList(_notificationKey, notifications);
  }
  
  // الحصول على جميع الإشعارات
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList(_notificationKey) ?? [];
    
    return notifications.map((notification) {
      return jsonDecode(notification) as Map<String, dynamic>;
    }).toList();
  }
  
  // تحديد إشعار كمقروء
  static Future<void> markAsRead(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList(_notificationKey) ?? [];
    
    if (index < notifications.length) {
      final notification = jsonDecode(notifications[index]) as Map<String, dynamic>;
      notification['read'] = true;
      notifications[index] = jsonEncode(notification);
      await prefs.setStringList(_notificationKey, notifications);
    }
  }
  
  // حذف إشعار
  static Future<void> deleteNotification(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList(_notificationKey) ?? [];
    
    if (index < notifications.length) {
      notifications.removeAt(index);
      await prefs.setStringList(_notificationKey, notifications);
    }
  }
  
  // حذف جميع الإشعارات
  static Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationKey);
  }
  
  // الحصول على عدد الإشعارات غير المقروءة
  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((notification) => notification['read'] == false).length;
  }
  
  // بدء فحص الإشعارات في الوقت الفعلي
  static void startRealTimeNotifications(Function(List<Map<String, dynamic>>) onNewNotifications) {
    _onNewNotifications = onNewNotifications;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkForNewNotifications();
    });
  }
  
  // إيقاف فحص الإشعارات في الوقت الفعلي
  static void stopRealTimeNotifications() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _onNewNotifications = null;
  }
  
  // فحص الإشعارات الجديدة من الخادم
  static Future<void> _checkForNewNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getString(_lastCheckKey);
      final currentTime = DateTime.now().toIso8601String();
      
      // هنا يمكن إضافة API call للتحقق من الإشعارات الجديدة
      // مثال: final response = await http.get(Uri.parse('http://10.0.2.2:8000/notifications/?since=$lastCheck'));
      
      // للآن سنستخدم فحص محلي
      final currentNotifications = await getNotifications();
      final lastCheckTime = lastCheck != null ? DateTime.parse(lastCheck) : DateTime.now().subtract(const Duration(days: 1));
      
      final newNotifications = currentNotifications.where((notification) {
        final notificationTime = DateTime.parse(notification['timestamp']);
        return notificationTime.isAfter(lastCheckTime);
      }).toList();
      
      if (newNotifications.isNotEmpty && _onNewNotifications != null) {
        _onNewNotifications!(newNotifications);
      }
      
      // تحديث وقت آخر فحص
      await prefs.setString(_lastCheckKey, currentTime);
    } catch (e) {
      // print('Error checking for new notifications: $e');
    }
  }
  
  // فحص حالة الطالب من الخادم
  static Future<Map<String, dynamic>> checkStudentStatus(String username) async {
    try {
      // نحتاج للحصول على user ID أولاً
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id_$username');
      
      if (userId == null) {
        return {
          'exists': false,
          'approved': false,
          'student_data': null,
        };
      }
      
      // استخدام نفس endpoint مثل getStudent
      final response = await http.get(
        Uri.parse("${InternetService.baseUrl}/student/?user=$userId"),
        headers: {
          "Content-Type": "application/json",
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['datum'] != null && data['datum'].isNotEmpty) {
          return {
            'exists': true,
            'approved': true, // إذا وصلنا هنا، فالطالب معتمد
            'student_data': data['datum'][0],
          };
        }
      } else if (response.statusCode == 403) {
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
    } catch (e) {
      // print('Error checking student status: $e');
      return {
        'exists': false,
        'approved': false,
        'student_data': null,
      };
    }
  }
  
  // إشعار موافقة على الطالب
  static Future<void> notifyStudentApproval(String studentName) async {
    await saveNotification(
      'تمت الموافقة على حسابك',
      'مرحباً $studentName، تمت الموافقة على طلب تسجيلك في GradPro. يمكنك الآن تسجيل الدخول واستخدام النظام.',
      'approval',
    );
  }
  
  // إشعار رفض الطالب
  static Future<void> notifyStudentRejection(String studentName, String reason) async {
    await saveNotification(
      'تم رفض طلب تسجيلك',
      'عذراً $studentName، تم رفض طلب تسجيلك في GradPro. السبب: $reason',
      'rejection',
    );
  }
  
  // Get pending students
  Future<List<Student>> getPendingStudents() async {
    try {
      final response = await _internetService.get('$STUDENT?is_approved=false', null);
      final body = _decodeResponse(response);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        if (data['datum'] != null) {
          return (data['datum'] as List)
              .map((studentData) => Student.fromJson(studentData))
              .toList();
        }
      }
      return [];
    } catch (e) {
      // print('Error getting pending students: $e');
      return [];
    }
  }
  
  // Get pending projects
  Future<List<Project>> getPendingProjects() async {
    try {
      final response = await _internetService.get('$PROJECT?is_approved=false', null);
      final body = _decodeResponse(response);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        if (data['datum'] != null) {
          return (data['datum'] as List)
              .map((projectData) => Project.fromJson(projectData))
              .toList();
        }
      }
      return [];
    } catch (e) {
      // print('Error getting pending projects: $e');
      return [];
    }
  }
  
  // Approve student
  Future<bool> approveStudent(int studentId) async {
    try {
      final response = await _internetService.patch('$STUDENT$studentId/', {
        'is_approved': true,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      // print('Error approving student: $e');
      return false;
    }
  }
  
  // Reject student
  Future<bool> rejectStudent(int studentId, String reason) async {
    try {
      final response = await _internetService.patch('$STUDENT$studentId/', {
        'is_approved': false,
        'rejection_reason': reason,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      // print('Error rejecting student: $e');
      return false;
    }
  }
  
  // Approve project
  Future<bool> approveProject(int projectId) async {
    try {
      final response = await _internetService.patch('$PROJECT$projectId/', {
        'is_approved': true,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      // print('Error approving project: $e');
      return false;
    }
  }
  
  // Reject project
  Future<bool> rejectProject(int projectId, String reason) async {
    try {
      final response = await _internetService.patch('$PROJECT$projectId/', {
        'is_approved': false,
        'rejection_reason': reason,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      // print('Error rejecting project: $e');
      return false;
    }
  }
  
  // Send real-time notifications
  Future<void> sendStudentApprovalNotification(int studentId) async {
    try {
      await _internetService.post('/api/notifications/student-approved/', {
        'student_id': studentId,
        'message': 'تمت الموافقة على طلبك بنجاح!',
        'type': 'student_approval',
      });
    } catch (e) {
      // print('Error sending student approval notification: $e');
    }
  }
  
  Future<void> sendStudentRejectionNotification(int studentId, String reason) async {
    try {
      await _internetService.post('/api/notifications/student-rejected/', {
        'student_id': studentId,
        'message': 'تم رفض طلبك: $reason',
        'type': 'student_rejection',
        'reason': reason,
      });
    } catch (e) {
      // print('Error sending student rejection notification: $e');
    }
  }
  
  Future<void> sendProjectApprovalNotification(int projectId) async {
    try {
      await _internetService.post('/api/notifications/project-approved/', {
        'project_id': projectId,
        'message': 'تمت الموافقة على مشروعك بنجاح!',
        'type': 'project_approval',
      });
    } catch (e) {
      // print('Error sending project approval notification: $e');
    }
  }
  
  Future<void> sendProjectRejectionNotification(int projectId, String reason) async {
    try {
      await _internetService.post('/api/notifications/project-rejected/', {
        'project_id': projectId,
        'message': 'تم رفض مشروعك: $reason',
        'type': 'project_rejection',
        'reason': reason,
      });
    } catch (e) {
      // print('Error sending project rejection notification: $e');
    }
  }
  
  // Helper method to decode response
  String _decodeResponse(http.Response response) {
    List<int> bodyBytes = response.bodyBytes;
    return utf8.decode(bodyBytes);
  }
} 
