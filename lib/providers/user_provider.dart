import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradpro/services/user_services.dart';
import 'package:gradpro/services/login_services.dart';
import 'package:gradpro/services/models_services.dart';
import 'package:gradpro/services/internet_services.dart';

import '../models/logging_state.dart';
import '../models/project_list.dart';
import '../models/student_list.dart';
import '../models/user_list.dart';

class UserProvider extends ChangeNotifier {
  final userServices = UserService();
  bool _loggedIn = false;
  bool invalidPassword = false;
  bool invalidEmail = false;
  bool _loginError = false;
  bool _isLoginLoading = false;
  bool _isVisible = false;
  
  bool get isVisible => _isVisible;
  int _group = 0;
  User? _user;
  Project? _studentProject;
  Student? _studentAccount;
  bool passwordChanged = false;
  String _errorMessage = "";
  bool _isPendingApproval = false;
  Map<String, dynamic>? _pendingStudentData;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController changePasswordController =
      TextEditingController();
  final TextEditingController changeOldPasswordController =
      TextEditingController();

  bool get loggedIn => _loggedIn;

  bool get loginError => _loginError;

  bool get isLoginLoading => _isLoginLoading;

  int get group => _group;

  User? get user => _user;

  Student? get student => _studentAccount;

  Project? get project => _studentProject;

  String get errorMessage => _errorMessage;

  bool get isPendingApproval => _isPendingApproval;

  Map<String, dynamic>? get pendingStudentData => _pendingStudentData;

  Future<Logging> get refreshLogin async {
    // تحميل التوكن من SharedPreferences قبل أي محاولة
    await InternetService().loadTokenFromPrefs();
    return await _switchLogin();
  }

  Future<void> loginUser(GlobalKey<FormState>? formKey) async {
    if (formKey?.currentState != null && formKey!.currentState!.validate()) {
      print('DEBUG: Starting login process...');
      print('DEBUG: Username entered: ${emailController.text}');
      print('DEBUG: Password entered: ${passwordController.text}');
      
      // مسح البيانات المحفوظة قبل تسجيل الدخول
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print('DEBUG: Cleared stored data before login');
      } catch (e) {
        print('DEBUG: Error clearing stored data: $e');
      }
      
      // Reset states
      _isPendingApproval = false;
      _pendingStudentData = null;
      _loginError = false;
      _errorMessage = "";
      _loggedIn = false;
      _user = null;
      _studentAccount = null;
      _studentProject = null;
      _group = 0;

      try {
        final bool loggedIn = await login(
            emailController.value.text, passwordController.value.text);
        _loggedIn = loggedIn;
        
        if (loggedIn) {
          // حفظ username في SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_username', emailController.value.text);
          
          // Load user and set group after successful login
          await _loadUser(emailController.value.text);
          _group = _user?.groups.first ?? 0; // Default to 0 for regular users
          print('DEBUG: User logged in - ID: ${_user?.id}, Group: $_group, Username: ${_user?.username}');
          print('DEBUG: User groups: ${_user?.groups}');
          
          // تحقق إضافي: إذا كان المستخدم طالب (group=2)، تحقق من اعتماده
          if (_group == 2) {
            try {
              await _loadStudent();
              print('DEBUG: User is a student (approved)');
            } catch (e) {
              print('DEBUG: User is a student but not approved - setting pending approval');
              _isPendingApproval = true;
              _loginError = true;
              _errorMessage = "حسابك قيد المراجعة من قبل الإدارة";
              _loggedIn = false;
              _user = null;
              _group = 0;
            }
          }
          
          // إذا كان الطالب معتمد، تأكد من توجيهه لصفحة الطالب
          if (_group == 2 && _studentAccount != null) {
            print('DEBUG: Student is approved, should go to student page');
          }
          
          final Logging loginState = await _switchLogin();
          
          if (loginState == Logging.notUser) {
            // إذا كان group=0 أو أي حالة غير مصرح بها
            _loginError = true;
            _errorMessage = "لا تملك صلاحية الدخول للنظام";
            _loggedIn = false;
            _user = null;
            _group = 0;
          } else if (loginState == Logging.admin || loginState == Logging.teacher) {
            // Valid login for admin and teacher
            _loginError = false;
            _errorMessage = "";
            _loggedIn = true;
          } else if (loginState == Logging.student) {
            // الطالب معتمد
            _loginError = false;
            _errorMessage = "";
            _loggedIn = true;
          } else {
            // Any other case
            _loginError = true;
            _errorMessage = "لا تملك صلاحية الدخول للنظام";
            _loggedIn = false;
            _user = null;
            _group = 0;
          }
        } else {
          _loginError = true;
          _errorMessage = "أسم المستخدم او كلمة المرور خاطئة";
          _user = null;
          _group = 0;
        }
      } catch (e) {
        if (e is PendingApprovalException) {
          // Handle pending approval
          _isPendingApproval = true;
          _pendingStudentData = e.studentData;
          _loginError = true;
          _errorMessage = e.message;
          _loggedIn = false;
          _user = null;
          _group = 0;
        } else if (e.toString().contains('Student not approved yet')) {
          // Handle student not approved - redirect to pending approval page
          _isPendingApproval = true;
          _loginError = true;
          _errorMessage = "حسابك قيد المراجعة من قبل الإدارة";
          _loggedIn = false;
          _user = null;
          _group = 0;
        } else {
          // Handle other errors
          _loginError = true;
          _errorMessage = "أسم المستخدم او كلمة المرور خاطئة";
          _loggedIn = false;
          _user = null;
          _group = 0;
        }
      }
      notifyListeners();
    }
  }

  void setUser(User? value) {
    _user = value;
  }

  Future<void> changePassword() async {
    try {
      await UserService().changePassword(
          changeOldPasswordController.text, changePasswordController.text);
      changeOldPasswordController.text = "";
      changePasswordController.text = "";
      passwordChanged = true;
    } catch (e) {
      changeOldPasswordController.text = "";
      changePasswordController.text = "";
      passwordChanged = false;
    }
    notifyListeners();
  }

  Future<Logging> _switchLogin() async {
    try {
      print('DEBUG: _switchLogin called - User: ${_user?.id}, Group: $_group');
      
      // If user is null, try to load user data
      if (_user == null) {
        print('DEBUG: User is null, loading user data...');
        await _loadUser();
      }

      // Now check if we have a valid user
      if (_user != null) {
        print('DEBUG: User loaded - ID: ${_user?.id}, Groups: ${_user?.groups}, Current Group: $_group');
        switch (_group) {
          case 1:
            print('DEBUG: Processing admin login for user ${_user?.id}');
            return Logging.admin; // Admin users
          case 2:
            try {
              print('DEBUG: Processing student login for user ${_user?.id}');
              // تحقق من أن الطالب محمل بالفعل
              if (_studentAccount == null) {
                await _loadStudent();
              }
              print('DEBUG: Student loaded successfully - ID: ${_studentAccount?.id}, Serial: ${_studentAccount?.serialNumber}');
              await _loadProject();
              return Logging.student; // Student users
            } catch (e) {
              print('DEBUG: Error loading student: $e');
              // الطالب غير معتمد أو غير موجود
              _loginError = true;
              _errorMessage = "حسابك قيد المراجعة من قبل الإدارة";
              return Logging.notUser;
            }
          case 3:
            print('DEBUG: Processing teacher login for user ${_user?.id}');
            return Logging.teacher; // Teacher users
          case 0:
            // مستخدم ليس له صلاحية
            print('DEBUG: User has no permissions (group 0)');
            return Logging.notUser;
          default:
            print('DEBUG: Unknown user group: $_group');
            return Logging.notUser;
        }
      }
      print('DEBUG: No valid user found, returning notUser');
      return Logging.notUser;
    } catch (e) {
      print('DEBUG: Error in _switchLogin: $e');
      _loginError = true;
      return Logging.notUser;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      // Add timeout to prevent hanging
      bool approved = await refreshLoginService().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Token refresh timeout');
        },
      );
      if (approved) {
        await _loadUser();
        if (_user != null) {
          // Set group to first group if available, otherwise 0 (regular user)
          _group = _user!.groups.isNotEmpty ? _user!.groups.first : 0;
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  String? passwordValidator(String? value) {
    if (value == null) {
      return 'password cannot be null';
    } else {
      if (value.isEmpty) {
        return 'الرجاء إدخال كلمة مرور';
      } else if (value.length < 8) {
        return 'كلمة المرور لا تقل عن 8 خانات';
      }
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null) {
      return 'user name cannot be null';
    } else {
      if (value.isEmpty) {
        return 'الرجاء إدخال إسم مستخدم';
      } else if (value.length < 4) {
        return 'إسم مستخدم لا يقل عن 4 خانات';
      } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
        return 'إسم المستخدم يحتوي علي رموز غير صحيحة';
      }
    }
    return null;
  }

  void setLoginLoading(bool value) {
    _isLoginLoading = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  Future<void> _loadUser([String? expectedUsername]) async {
    try {
      print('DEBUG: Loading user data from API...');
      print('DEBUG: Current login username: $expectedUsername');
      
      // إذا كان لدينا username محفوظ، استخدمه
      if (expectedUsername == null) {
        final prefs = await SharedPreferences.getInstance();
        expectedUsername = prefs.getString('current_username');
        print('DEBUG: Retrieved username from prefs: $expectedUsername');
      }
      
      _user = await getMyAccount(expectedUsername);
      print('DEBUG: User loaded from API - ID: ${_user?.id}, Username: ${_user?.username}, Groups: ${_user?.groups}');
      notifyListeners();
    } catch (e) {
      print('DEBUG: Error loading user: $e');
      _user = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadStudent() async {
    try {
      print('DEBUG: Attempting to load student data...');
      print('DEBUG: Current user ID: ${_user?.id}');
      print('DEBUG: Current user groups: ${_user?.groups}');
      print('DEBUG: Student already loaded: ${_studentAccount != null}');
      
      // إذا كان الطالب محمل بالفعل، لا نحمل مرة أخرى
      if (_studentAccount != null) {
        print('DEBUG: Student already loaded, skipping...');
        return;
      }
      
      if (_user != null) {
        print('DEBUG: Calling userServices.student...');
        _studentAccount = await userServices.student.timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            print('DEBUG: Student load timeout');
            throw Exception('Student load timeout');
          },
        );
        
        print('DEBUG: Student loaded - ID: ${_studentAccount?.id}, Serial: ${_studentAccount?.serialNumber}');
        print('DEBUG: Student isApproved: ${_studentAccount?.isApproved}');
        print('DEBUG: Student user: ${_studentAccount?.user}');
        
        // تحقق من أن الطالب معتمد
        if (_studentAccount == null) {
          print('DEBUG: Student is null - not approved');
          throw Exception('Student not approved yet');
        }
        
        // تحقق إضافي من حالة الموافقة
        if (_studentAccount?.isApproved == false) {
          print('DEBUG: Student isApproved is false - not approved');
          throw Exception('Student not approved yet');
        }
        
        print('DEBUG: Student is approved and loaded successfully');
        notifyListeners();
      } else if (_user == null) {
        print('DEBUG: User is null, cannot load student');
        throw Exception('User not loaded');
      } else {
        print('DEBUG: Student already loaded or user is not a student');
      }
    } catch (e) {
      print('DEBUG: Error loading student: $e');
      _studentAccount = null;
      notifyListeners();
      // نرمي الاستثناء مرة أخرى لمعالجته في دالة تسجيل الدخول
      rethrow;
    }
  }

  Future<void> _loadProject() async {
    try {
      print('DEBUG: Attempting to load project data...');
      print('DEBUG: Project already loaded: ${_studentProject != null}');
      
      // إذا كان المشروع محمل بالفعل، لا نحمل مرة أخرى
      if (_studentProject != null) {
        print('DEBUG: Project already loaded, skipping...');
        return;
      }
      
      if (_studentAccount?.project != null) {
        print('DEBUG: Loading project for student ${_studentAccount?.id}');
        _studentProject = await userServices.project.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('DEBUG: Project load timeout');
            throw Exception('Project load timeout');
          },
        );
        print('DEBUG: Project loaded successfully - ID: ${_studentProject?.id}');
        notifyListeners();
      } else {
        print('DEBUG: No project assigned to student');
      }
    } catch (e) {
      print('DEBUG: Error loading project: $e');
      _studentProject = null;
      notifyListeners();
    }
  }

  void setGroup(int group) {
    _group = group;
    notifyListeners();
  }

  Future<void> updateUserFirstName() async {
    if (_user != null) {
      if (firstNameController.text.isNotEmpty) {
        _user = await userServices.updateUserFirstName(
            _user!.id, firstNameController.text);
        notifyListeners();
      }
    }
  }

  Future<void> updateUserLastName() async {
    if (_user != null) {
      if (lastNameController.text.isNotEmpty) {
        _user = await userServices.updateUserLastName(
            _user!.id, lastNameController.text);
      }
      notifyListeners();
    }
  }

  void logout() async {
    print('DEBUG: Logging out user...');
    
    // مسح البيانات المحفوظة
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _loggedIn = false;
    _user = null;
    _studentAccount = null;
    _studentProject = null;
    _group = 0;
    _loginError = false;
    _errorMessage = "";
    _isPendingApproval = false;
    _pendingStudentData = null;
    
    print('DEBUG: User logged out successfully');
    notifyListeners();
  }

  /// إعادة تحميل بيانات المستخدم والطالب بعد الموافقة
  Future<void> reloadUserAndStudent() async {
    await _loadUser();
    if (_user != null && _user!.groups.contains(2)) {
      _studentAccount = null;
      await _loadStudent();
    }
    notifyListeners();
  }
}
