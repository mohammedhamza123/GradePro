import 'package:flutter/cupertino.dart';

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

  bool get canRegister => _canRegister;

  bool get isLoading => _isLoading;

  String get error => _error;
  String _success = "";

  String get success => _success;

  Future<void> register(bool isTeacher,bool? isExaminer) async {
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
        if(isExaminer != null){
          if (res != null) {
            final teacher = await getTeacher(res.id);
            if (teacher != null) {
              await patchTeacher(teacher.id, null, isExaminer);
            }
          }
        }
      } else {
        final res = await registerUser(user);
        if (res != null) {
          final std = await getStudent(res.id);
          if (std != null) {
            await patchStudent(
                std.id, null, null, int.parse(serialNumber.text.trim()));
          }
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
      _isLoading = false;
      _success = "تم التسجيل بنجاح";
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
}
