import 'package:flutter/cupertino.dart';
import '../models/student_details_list.dart';
import '../services/models_services.dart';
import '../services/internet_services.dart';

class AdminEditStudentProvider extends ChangeNotifier {
  StudentDetail? _student;
  Future<List<StudentDetail>>? _studentFuture;
  StudentDetail? get student => _student;

  List<StudentDetail> _studentList = [];
  List<StudentDetail> _filteredStudentList = [];

  TextEditingController searchbarController = TextEditingController();

  List<StudentDetail> get filterList => _filteredStudentList;

  List<StudentDetail> get studentList => _studentList;

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

  bool _canEdit = false;
  bool _isLoading = false;

  bool get canEdit => _canEdit;

  bool get isLoading => _isLoading;

  String get error => _error;

  Future<void> updateStudent() async {
    _isLoading = true;
    if (_student != null) {
      final user = _student!.user;
      try {
        await patchStudent(
            _student!.id, null, null, int.parse(serialNumber.text.trim()));
        await patchUser(
            user.id, firstName.text, lastName.text, userName.text, email.text);
        email.text = '';
        password.text = "";
        confirmPassword.text = "";
        userName.text = "";
        lastName.text = "";
        firstName.text = "";
        serialNumber.text = "";
        _isLoading = false;
        _canEdit = false;
        _error = "";
        _student = null;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        if (_error.length > 150) {
          _error = _error.substring(0, 150);
        }
        _isLoading = false;
        notifyListeners();
      }
    }
    notifyListeners();
  }
  
  Future<List<StudentDetail>> loadStudents() async {
    _studentFuture ??= _fetchStudents(); 
    return _studentFuture!;
  }
  
  Future<List<StudentDetail>> _fetchStudents() async {
    // Check if user is authenticated before making API call
    final InternetService services = InternetService();
    if (!services.isAuthorized()) {
      // Return empty list if not authenticated
      _studentList = [];
      notifyListeners();
      return _studentList;
    }
    
    try {
      final data = await getStudentDetailsList();
      _studentList = data.studentDetails;
      notifyListeners();
      return _studentList;
    } catch (e) {
      // If API call fails, return empty list
      _studentList = [];
      notifyListeners();
      return _studentList;
    }
  }

  void filterStudentList() {
    if (searchbarController.text.isEmpty) {
      _filteredStudentList = [];
      notifyListeners();
    } else {
      final String text = searchbarController.text.toLowerCase();
      _filteredStudentList = _studentList
          .where((e) =>
              e.user.firstName.toLowerCase().contains(text) ||
              e.user.lastName.toLowerCase().contains(text) ||
              e.user.username.toLowerCase().contains(text) ||
              (e.user.email?.toLowerCase().contains(text) ?? false))
          .toList();
      notifyListeners();
    }
  }

  Future<void> deleteStudent(int id, int index, bool isList) async {
    try {
      await delStudent(id);
      // حذف الطالب من القائمة الأصلية
      _studentList.removeWhere((student) => student.id == id);
      // حذف الطالب من القائمة المفلترة
      _filteredStudentList.removeWhere((student) => student.id == id);
      // إعادة تعيين الطالب الحالي إذا كان هو المحذوف
      if (_student != null && _student!.id == id) {
        _student = null;
      }
      notifyListeners();
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  void setStudent(item) {
    _student = item;
    if (_student != null) {
      userName.text = _student!.user.username;
      firstName.text = _student!.user.firstName;
      lastName.text = _student!.user.lastName;
      email.text = _student!.user.email ?? '';
      serialNumber.text = _student!.serialNumber?.toString() ?? '';
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

  String? validateSerial(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return "رقم القيد يتكون من ارقام فقط";
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
