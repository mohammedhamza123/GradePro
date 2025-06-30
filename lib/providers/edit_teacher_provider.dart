import 'package:flutter/cupertino.dart';
import '../models/teacher_details_list.dart';
import '../services/models_services.dart';

import 'dart:async';
import 'package:flutter/material.dart';

class AdminEditTeacherProvider extends ChangeNotifier {
  TeacherDetail? _teacher;

  TeacherDetail? get teacher => _teacher;

  List<TeacherDetail> _teacherList = [];
  List<TeacherDetail> _filteredTeacherList = [];

  TextEditingController searchbarController = TextEditingController();

  List<TeacherDetail> get filterList => _filteredTeacherList;

  List<TeacherDetail> get teacherList => _teacherList;

  List<TeacherDetail> get examinerList =>
      _teacherList.where((element) => element.isExaminer == true).toList();
  List<TeacherDetail> get filterExaminerList => _filteredTeacherList
      .where((element) => element.isExaminer == true)
      .toList();

  String _error = "";

  final _formKey = GlobalKey<FormState>();

  GlobalKey<FormState> get formKey => _formKey;

  TextEditingController email = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool _canEdit = false;
  bool _isLoading = false;

  bool get canEdit => _canEdit;

  bool get isLoading => _isLoading;

  String get error => _error;

  bool _isLoadingTeachers =
      false; // متغير لتحديد إذا كانت بيانات المعلمين محملة

  Timer? _debounce;

  Future<void> updateTeacher() async {
    _isLoading = true;
    final user = _teacher!.user;
    try {
      await patchUser(
          user.id, firstName.text, lastName.text, userName.text, email.text);
      email.text = '';
      password.text = "";
      confirmPassword.text = "";
      userName.text = "";
      lastName.text = "";
      firstName.text = "";
      _isLoading = false;
      _canEdit = false;
      _error = "";
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (_error.length > 150) {
        _error = _error.substring(0, 150);
      }
      _isLoading = false;
      _canEdit = false;
      notifyListeners();
    }
  }

  Future<List<TeacherDetail>> loadTeachers() async {
    if (_isLoadingTeachers) {
      // إذا كانت البيانات محملة مسبقًا أو أن العملية ما زالت قيد التنفيذ، لا نقوم بإرسال طلب مرة أخرى
      return _teacherList;
    }

    _isLoadingTeachers = true;
    final data = await getTeacherDetailsList();
    _teacherList = data.teacher;
    _isLoadingTeachers = false;
    notifyListeners();
    return _teacherList;
  }

  Future<List<TeacherDetail>> loadExaminers() async {
    if (_teacherList.isEmpty) {
      final data = await getTeacherDetailsList();
      _teacherList = data.teacher;
      notifyListeners();
    }
    return _teacherList.where((element) => element.isExaminer == true).toList();
  }

  void filterTeacherList() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchbarController.text.isEmpty) {
        _filteredTeacherList = [];
        notifyListeners();
      } else {
        final String text = searchbarController.text;
        _filteredTeacherList = _teacherList
            .where((e) =>
                e.user.firstName.contains(text) ||
                e.user.lastName.contains(text) ||
                e.user.username.contains(text))
            .toList();
        notifyListeners();
      }
    });
  }

  Future<void> deleteTeacher(int id, int index, bool isList) async {
    try {
      await delTeacher(id);
    } catch (e) {
      rethrow;
    }
    if (!isList) {
      _teacherList.removeAt(index);
    } else {
      _filteredTeacherList.removeAt(index);
    }
    notifyListeners();
  }

  void setTeacher(item) {
    _teacher = item;
    if (_teacher != null) {
      userName.text = _teacher!.user.username;
      firstName.text = _teacher!.user.firstName;
      lastName.text = _teacher!.user.lastName;
    }
    notifyListeners();
  }

  void onFromStateChanged() {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _canEdit = true;
      } else {
        _canEdit = false;
      }
    } else {
      _canEdit = false;
    }
    notifyListeners();
  }

  String? validateUserName(String? value) {
    if (value!.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[\w.@+-]+$').hasMatch(value)) {
      return 'اسم المستخدم غير صالح';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[\w.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'هذا البريد غير صالح';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < 8) {
      return 'كلمة المرور قصيرة يجب ان تكون 8 احرف علي الاقل';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return null;
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
      return null;
    }
    return null;
  }
}
