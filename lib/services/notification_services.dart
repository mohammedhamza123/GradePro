import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class NotificationService {
  static const String _notificationKey = 'notifications';
  static const String _lastCheckKey = 'last_notification_check';
  static Timer? _pollingTimer;
  static Function(List<Map<String, dynamic>>)? _onNewNotifications;
  
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
      print('Error checking for new notifications: $e');
    }
  }
  
  // فحص حالة الطالب من الخادم
  static Future<Map<String, dynamic>> checkStudentStatus(String username) async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/student/?user=$username"),
        headers: {
          "Content-Type": "application/json",
        },
      );
      
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
      'مرحباً $studentName، تمت الموافقة على طلب تسجيلك في Gradify. يمكنك الآن تسجيل الدخول واستخدام النظام.',
      'approval',
    );
  }
  
  // إشعار رفض الطالب
  static Future<void> notifyStudentRejection(String studentName, String reason) async {
    await saveNotification(
      'تم رفض طلب تسجيلك',
      'عذراً $studentName، تم رفض طلب تسجيلك في Gradify. السبب: $reason',
      'rejection',
    );
  }
} 
