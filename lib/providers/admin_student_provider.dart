import 'package:flutter/cupertino.dart';
import 'package:gradpro/services/models_services.dart';
import 'package:gradpro/services/internet_services.dart';
import 'package:gradpro/services/notification_services.dart';
import 'package:gradpro/models/user_list.dart';

import '../models/student_details_list.dart';

class AdminStudentProvider extends ChangeNotifier {
  List<StudentDetail> _studentList = [];
  List<StudentDetail> _filteredStudentList = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  TextEditingController searchbarController = TextEditingController();

  List<StudentDetail> get filterList => _filteredStudentList;
  List<StudentDetail> get studentList => _studentList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<List<StudentDetail>> loadStudents() async {
    if (!_isInitialized) {
      return await _fetchStudents();
    }
    return _studentList;
  }

  // إضافة دالة لتحديث القائمة
  Future<List<StudentDetail>> refreshStudents() async {
    if (_isLoading) {
      return _studentList;
    }
    
    _error = null; // مسح الأخطاء السابقة
    return await _fetchStudents();
  }

  Future<List<StudentDetail>> _fetchStudents() async {
    // منع الطلبات المتعددة المتزامنة
    if (_isLoading) {
      print('Already loading students, skipping request');
      return _studentList;
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
        _studentList = [];
        _isLoading = false;
        _error = 'المستخدم غير مصرح له';
        _isInitialized = true;
        notifyListeners();
        return _studentList;
      }
      
      print('Fetching students from API...');
      final data = await getStudentDetailsList();
      _studentList = data.studentDetails;
      print('Successfully fetched ${_studentList.length} students');
      
      // طباعة معلومات الطلبة للتأكد
      for (int i = 0; i < _studentList.length; i++) {
        final student = _studentList[i];
        print('Student $i: ${student.user.firstName} ${student.user.lastName} - Approved: ${student.isApproved}');
      }
      
      _isLoading = false;
      _error = null;
      _isInitialized = true;
      notifyListeners();
      return _studentList;
    } catch (e) {
      print('Error fetching students: $e');
      _error = e.toString();
      _studentList = [];
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
      return _studentList;
    }
  }

  void filterStudentList() {
    if (searchbarController.text.isEmpty) {
      _filteredStudentList = [];
    } else {
      final String text = searchbarController.text;
      _filteredStudentList = _studentList
          .where((e) =>
              e.user.firstName.toLowerCase().contains(text.toLowerCase()) ||
              e.user.lastName.toLowerCase().contains(text.toLowerCase()) ||
              e.user.username.toLowerCase().contains(text.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> deleteStudent(int id, int index, bool isList) async {
    try {
      await delStudent(id);
      if (!isList) {
        _studentList.removeAt(index);
      } else {
        _filteredStudentList.removeAt(index);
      }
      notifyListeners();
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  // وظائف الموافقة والرفض
  Future<void> approveStudent(int studentId) async {
    try {
      print('Approving student with ID: $studentId');
      // استدعاء API للموافقة على الطالب
      await approveStudentAPI(studentId);
      
      // إرسال إشعار للموافقة
      final student = _studentList.firstWhere((s) => s.id == studentId);
      final studentName = '${student.user.firstName} ${student.user.lastName}';
      await NotificationService.notifyStudentApproval(studentName);
      
      // تحديث القائمة المحلية مباشرة بدلاً من إعادة التحميل
      final studentIndex = _studentList.indexWhere((student) => student.id == studentId);
      if (studentIndex != -1) {
        _studentList[studentIndex] = _studentList[studentIndex].copyWith(isApproved: true);
      }
      
      // تحديث القائمة المفلترة
      final filteredIndex = _filteredStudentList.indexWhere((student) => student.id == studentId);
      if (filteredIndex != -1) {
        _filteredStudentList[filteredIndex] = _filteredStudentList[filteredIndex].copyWith(isApproved: true);
      }
      
      notifyListeners();
      print('Student approved successfully');
    } catch (e) {
      print('Error approving student: $e');
      rethrow;
    }
  }

  Future<void> rejectStudent(int studentId, {String reason = 'لم يتم تحديد سبب'}) async {
    try {
      print('Rejecting student with ID: $studentId');
      // حفظ اسم الطالب قبل حذفه
      final student = _studentList.firstWhere((s) => s.id == studentId);
      final studentName = '${student.user.firstName} ${student.user.lastName}';
      
      // استدعاء API لرفض الطالب وحذفه
      await rejectStudentAPI(studentId);
      
      // إرسال إشعار للرفض
      await NotificationService.notifyStudentRejection(studentName, reason);
      
      // حذف الطالب من القائمة المحلية مباشرة بدلاً من إعادة التحميل
      _studentList.removeWhere((student) => student.id == studentId);
      
      // حذف الطالب من القائمة المفلترة
      _filteredStudentList.removeWhere((student) => student.id == studentId);
      
      notifyListeners();
      print('Student rejected successfully');
    } catch (e) {
      print('Error rejecting student: $e');
      rethrow;
    }
  }

  // الحصول على الطلاب الذين ينتظرون الموافقة
  List<StudentDetail> get pendingStudents {
    return _studentList.where((student) => student.isApproved == false).toList();
  }

  // الحصول على الطلاب المعتمدين
  List<StudentDetail> get approvedStudents {
    return _studentList.where((student) => student.isApproved == true).toList();
  }

  // مسح البحث
  void clearSearch() {
    searchbarController.clear();
    _filteredStudentList = [];
    notifyListeners();
  }

  // مسح الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // تحديث بيانات الطالب
  Future<void> updateStudentData(
    int studentId,
    String firstName,
    String lastName,
    String userName,
    String email,
    String serialNumber,
  ) async {
    try {
      // تحديث بيانات المستخدم
      await patchUser(
        _studentList.firstWhere((s) => s.id == studentId).user.id,
        firstName,
        lastName,
        userName,
        email,
      );
      
      // تحديث بيانات الطالب
      await patchStudent(
        studentId,
        null,
        null,
        int.tryParse(serialNumber),
      );
      
      // تحديث القائمة المحلية
      final studentIndex = _studentList.indexWhere((s) => s.id == studentId);
      if (studentIndex != -1) {
        final oldUser = _studentList[studentIndex].user;
        final updatedUser = User(
          id: oldUser.id,
          firstName: firstName,
          lastName: lastName,
          username: userName,
          email: email,
          groups: oldUser.groups,
        );
        final updatedStudent = _studentList[studentIndex].copyWith(
          user: updatedUser,
          serialNumber: int.tryParse(serialNumber),
        );
        _studentList[studentIndex] = updatedStudent;
      }
      
      notifyListeners();
    } catch (e) {
      print('Error updating student data: $e');
      rethrow;
    }
  }
}
