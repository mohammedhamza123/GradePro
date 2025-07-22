import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/models_services.dart';

class RegisterProvider extends ChangeNotifier {
  String _error = "";

  final _formKey = GlobalKey<FormState>();

  GlobalKey<FormState> get formKey => _formKey;

  TextEditingController email = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController serialNumber = TextEditingController();

  bool _canRegister = false;
  bool _isLoading = false;
  bool _isExaminer = false;
  bool get isExaminer => _isExaminer;
  set isExaminer(bool value) {
    _isExaminer = value;
    notifyListeners();
  }

  bool get canRegister => _canRegister;

  bool get isLoading => _isLoading;

  String get error => _error;
  String _success = "";

  String get success => _success;

  Future<void> register(bool isTeacher, bool? isExaminer) async {
    _isLoading = true;
    notifyListeners();
    int group = 2;
    if (isTeacher) {
      group = 3;
    }
    final Map<String, dynamic> user = {
      "username": userName.text,
      "password": password.text,
      "password2": confirmPassword.text,
      "email": email.text,
      "first_name": firstName.text,
      "last_name": lastName.text,
      "groups": [group]
    };
    try {
      if (isTeacher) {
        final res = await registerUser(user);
        if (isExaminer != null) {
          if (res != null) {
            final teacher = await getTeacher(res.id);
            if (teacher != null) {
              await patchTeacher(teacher.id, null, isExaminer, null);
            }
          }
        }
      } else {
        final res = await registerUser(user);
        if (res != null) {
          // Save serial number and user ID for later use when student is approved
          if (serialNumber.text.trim().isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
                'pending_serial_${res.id}', serialNumber.text.trim());
            await prefs.setInt('user_id_${userName.text}', res.id);
          }

          // Save password temporarily for auto-login after approval
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'temp_password_${userName.text}', password.text);

          // Try to get student - this might fail if student is not approved yet
          try {
            final std = await getStudent(res.id);
            if (std != null) {
              // If student is already approved, update serial number immediately
              if (serialNumber.text.trim().isNotEmpty) {
                await patchStudent(
                    std.id, null, null, int.parse(serialNumber.text.trim()));
              }
            }
          } catch (e) {
            // Student is not approved yet - this is expected for new registrations
          }
          // If student is not approved yet, serial number will be set after approval
        }
      }

      // Clear form
      email.text = '';
      password.text = "";
      confirmPassword.text = "";
      userName.text = "";
      lastName.text = "";
      firstName.text = "";
      serialNumber.text = "";
      _isExaminer = false;
      _isLoading = false;
      _success =
          "تم التسجيل بنجاح! سيتم مراجعة طلبك من قبل الإدارة قبل تفعيل الحساب.";
      _error = "";
      _canRegister = false;
      notifyListeners();

      // Navigate to pending approval page
      // Note: Navigation will be handled in the UI layer
    } catch (e) {
      _error = e.toString();
      if (_error.length > 150) {
        _error = _error.substring(0, 140);
      }
      _isLoading = false;
      _success = "";
      _canRegister = false;
      notifyListeners();
    }
  }

  void onFromStateChanged() {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _canRegister = true;
      } else {
        _canRegister = false;
      }
    } else {
      _canRegister = false;
    }
    _success = "";
    _error = "";
    notifyListeners();
  }

  String? validateUserName(String? value) {
    if (value!.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (!RegExp(r'^[\w.@+-]+$').hasMatch(value)) {
      return 'اسم المستخدم غير صالح';
    }
    return null;
  }

  String? validateSerial(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return "رقم القيد يتكون من ارقام فقط";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (!RegExp(r'^[\w.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'هذا البريد غير صالح';
    }
    return null;
  }

  // دالة للتحقق من توفر البريد الإلكتروني
  Future<String?> checkEmailAvailability(String email) async {
    try {
      // يمكن إضافة API endpoint للتحقق من توفر البريد الإلكتروني
      // حالياً سنعتمد على رسالة الخطأ من الخادم
      return null;
    } catch (e) {
      return 'خطأ في التحقق من البريد الإلكتروني';
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 8) {
      return 'كلمة المرور قصيرة يجب ان تكون 8 احرف علي الاقل';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجي اعادة كتابة كلمة المرور';
    }
    if (value.length < 8) {
      return 'كلمة المرور قصيرة يجب ان تكون 8 احرف علي الاقل';
    }
    if (password.value.text != value) {
      return 'يرجي التاكيد من كلمة المرور غير مشابهه';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجي ادخال اسم';
    }
    return null;
  }

  // دالة لاسترجاع السيريال نمبر المحفوظ
  static Future<String?> getPendingSerialNumber(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pending_serial_$userId');
  }

  // دالة لحذف السيريال نمبر المحفوظ بعد استخدامه
  static Future<void> clearPendingSerialNumber(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_serial_$userId');
  }
}
