import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradpro/services/user_services.dart';
import 'package:gradpro/services/login_services.dart';
import 'package:gradpro/services/models_services.dart';
import 'package:gradpro/services/internet_services.dart';
import 'package:gradpro/services/token_manager.dart';

import '../models/logging_state.dart';
import '../models/project_list.dart';
import '../models/student_list.dart';
import '../models/user_list.dart';

class UserProvider extends ChangeNotifier {
  final userServices = UserService();
  final InternetService _internetService = InternetService();
  final LoginService loginService = LoginService();
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
    try {
      // إذا كان المستخدم محمل بالفعل، ارجع الحالة الحالية
      if (_user != null && _loggedIn) {
        return await _switchLogin();
      }
      
      // تحميل التوكن من SharedPreferences بسرعة
      await _internetService.loadTokenFromPrefs();
      
      // انتظار قصير جداً
      await Future.delayed(const Duration(milliseconds: 50));
      
      // محاولة تحديث التوكن أولاً
      bool tokenRefreshed = await _refreshToken();
      if (tokenRefreshed) {
        return await _switchLogin();
      }
      
      // إذا فشل تحديث التوكن، تحقق من وجود توكن صالح
      if (_internetService.isAuthorized()) {
        await _loadUser();
        if (_user != null) {
          _group = _user!.groups.isNotEmpty ? _user!.groups.first : 0;
          return await _switchLogin();
        }
      }
      
      return Logging.notUser;
    } catch (e) {
      return Logging.notUser;
    }
  }

  Future<void> loginUser(GlobalKey<FormState>? formKey) async {
    if (formKey?.currentState != null && formKey!.currentState!.validate()) {
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
          // Load user and set group after successful login
          await _loadUser(emailController.value.text);
          _group = _user?.groups.first ?? 0; // Default to 0 for regular users
          
          // تحقق إضافي: إذا كان المستخدم طالب (group=2)، تحقق من اعتماده
          if (_group == 2) {
            try {
              await _loadStudent();
            } catch (e) {
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
    // If user is null, try to load user data
    if (_user == null) {
      await _loadUser();
    }

    // Now check if we have a valid user
    if (_user != null) {
      switch (_group) {
        case 1:
          return Logging.admin; // Admin users
        case 2:
          try {
            // تحقق من أن الطالب محمل بالفعل
            if (_studentAccount == null) {
              await _loadStudent();
            }
            await _loadProject();
            return Logging.student; // Student users
          } catch (e) {
            return Logging.notUser;
          }
        case 3:
          return Logging.teacher; // Teacher users
        case 0:
          // مستخدم ليس له صلاحية
          return Logging.notUser;
        default:
          return Logging.notUser;
      }
    }
    
    return Logging.notUser;
  }

  Future<bool> _refreshToken() async {
    // إذا كان المستخدم محمل بالفعل، لا حاجة للتحديث
    if (_user != null && _loggedIn) {
      return true;
    }
    
    // انتظار قصير جداً قبل محاولة التحديث
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Add timeout to prevent hanging
    bool approved = await refreshLoginService().timeout(
      const Duration(seconds: 5),
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
    // إذا كان المستخدم محمل بالفعل، لا نحمل مرة أخرى
    if (_user != null) {
      return;
    }
    
    // إذا كان لدينا username محفوظ، استخدمه
    if (expectedUsername == null) {
      final prefs = await SharedPreferences.getInstance();
      expectedUsername = prefs.getString('current_username');
    }
    
    // Add timeout to prevent hanging
    _user = await getMyAccount(expectedUsername).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('User load timeout');
      },
    );
    
    notifyListeners();
  }

  Future<void> _loadStudent() async {
    // إذا كان الطالب محمل بالفعل، لا نحمل مرة أخرى
    if (_studentAccount != null) {
      return;
    }
    
    if (_user != null) {
      _studentAccount = await userServices.student.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Student load timeout');
        },
      );
      
      // تحقق من أن الطالب معتمد
      if (_studentAccount == null) {
        throw Exception('Student not approved yet');
      }
      
      // تحقق إضافي من حالة الموافقة
      if (_studentAccount?.isApproved == false) {
        throw Exception('Student not approved yet');
      }
      
      notifyListeners();
    } else if (_user == null) {
      throw Exception('User not loaded');
    } else {
    }
  }

  Future<void> _loadProject() async {
    // إذا كان المشروع محمل بالفعل، لا نحمل مرة أخرى
    if (_studentProject != null) {
      return;
    }
    
    if (_studentAccount?.project != null) {
      _studentProject = await userServices.project.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Project load timeout');
        },
      );
      notifyListeners();
    } else {
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
    // مسح جميع البيانات المحلية أولاً
    _loggedIn = false;
    _user = null;
    _studentAccount = null;
    _studentProject = null;
    _group = 0;
    _loginError = false;
    _errorMessage = "";
    _isPendingApproval = false;
    _pendingStudentData = null;
    
    // مسح التوكن من InternetService
    _internetService.removeToken();
    
    // مسح البيانات المحفوظة باستخدام TokenManager
    await TokenManager.clearAllTokens();
    
    // استدعاء دالة تسجيل الخروج من LoginService
    await loginService.logout();
    
    // مسح البيانات المحفوظة في UserService أيضاً
    final userService = UserService();
    userService.clearData();
    
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
