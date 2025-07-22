import 'package:flutter/cupertino.dart';
import 'package:gradpro/services/models_services.dart';
import 'package:gradpro/services/internet_services.dart';

import '../models/teacher_details_list.dart';

class AdminTeacherProvider extends ChangeNotifier {
  List<TeacherDetail> _teacherList = [];
  List<TeacherDetail> _filteredTeacherList = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  TextEditingController searchbarController = TextEditingController();

  List<TeacherDetail> get filterList => _filteredTeacherList;
  List<TeacherDetail> get teacherList => _teacherList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  List<TeacherDetail> get examinerList =>
      _teacherList.where((element) => element.isExaminer == true).toList();
  List<TeacherDetail> get filterExaminerList => _filteredTeacherList
      .where((element) => element.isExaminer == true)
      .toList();

  Future<List<TeacherDetail>> loadTeachers() async {
    if (!_isInitialized) {
      return await _fetchTeachers();
    }
    return _teacherList;
  }

  // إضافة دالة لتحديث القائمة
  Future<List<TeacherDetail>> refreshTeachers() async {
    // منع الطلبات المتعددة المتزامنة
    if (_isLoading) {
      return _teacherList;
    }
    
    _error = null; // مسح الأخطاء السابقة
    return await _fetchTeachers();
  }

  Future<List<TeacherDetail>> _fetchTeachers() async {
    // منع الطلبات المتعددة المتزامنة
    if (_isLoading) {
      return _teacherList;
    }
    
    _isLoading = true;
    _error = null;
    
    // تأخير قليل لتجنب استدعاء notifyListeners أثناء البناء
    await Future.delayed(const Duration(milliseconds: 100));
    
    notifyListeners();
    
    try {
      // Check if user is authenticated before making API call
      final InternetService services = InternetService();
      if (!services.isAuthorized()) {
        print('User not authorized, returning empty list');
        _teacherList = [];
        _isLoading = false;
        _error = 'المستخدم غير مصرح له';
        _isInitialized = true;
        notifyListeners();
        return _teacherList;
      }
      
      print('Fetching teachers from API...');
      final data = await getTeacherDetailsList();
      _teacherList = data.teacher;
      print('Successfully fetched ${_teacherList.length} teachers');
      
      _isLoading = false;
      _error = null;
      _isInitialized = true;
      notifyListeners();
      return _teacherList;
    } catch (e) {
      print('Error fetching teachers: $e');
      _error = e.toString();
      _teacherList = [];
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
      return _teacherList;
    }
  }

  Future<List<TeacherDetail>> loadExaminer() async {
    await loadTeachers(); // ✅ تحميل المعلمين مرة واحدة فقط
    return examinerList; // ✅ استخدام البيانات المحملة بدلًا من تحميلها مجددًا
  }

  void filterTeacherList() {
    if (searchbarController.text.isEmpty) {
      _filteredTeacherList = [];
    } else {
      final String text = searchbarController.text;
      _filteredTeacherList = _teacherList
          .where((e) =>
              e.user.firstName.toLowerCase().contains(text.toLowerCase()) ||
              e.user.lastName.toLowerCase().contains(text.toLowerCase()) ||
              e.user.username.toLowerCase().contains(text.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> deleteTeacher(int id, int index, bool isList) async {
    try {
      await delTeacher(id);
      if (!isList) {
        _teacherList.removeAt(index);
      } else {
        _filteredTeacherList.removeAt(index);
      }
      notifyListeners();
    } catch (e) {
      print('Error deleting teacher: $e');
      rethrow;
    }
  }

  // مسح البحث
  void clearSearch() {
    searchbarController.clear();
    _filteredTeacherList = [];
    notifyListeners();
  }

  // مسح الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> patchTeacherExaminer(int teacherId, bool isExaminer) async {
    try {
      await patchTeacher(teacherId, null, isExaminer,null);
      final index = _teacherList.indexWhere((t) => t.id == teacherId);
      if (index != -1) {
        _teacherList[index].isExaminer = isExaminer;
        notifyListeners();
      }
    } catch (e) {
      print('Error patching teacher examiner: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  TeacherDetail? getTeacherById(int? id) {
    if (id == null) return null;
    try {
      return _teacherList.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
