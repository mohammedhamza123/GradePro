import '../models/project_list.dart';
import '../models/student_list.dart';
import '../models/user_list.dart';
import 'models_services.dart';
import 'internet_services.dart';

class UserService {
  static final UserService _userService = UserService._internal();

  factory UserService() {
    return _userService;
  }

  UserService._internal();

  User? _user;
  Project? _studentProject;
  Student? _studentAccount;

  Future<User?> get user async => await _getUser();

  Future<Student?> get student => _getStudent();

  Future<Project?> get project => _getProject();

  Future<User?> _getUser() async {
    // Check if user is authenticated before making API call
    final InternetService services = InternetService();
    if (!services.isAuthorized()) {
      return null;
    }
    
    try {
      _user = await getMyAccount();
      return _user;
    } catch (e) {
      return null;
    }
  }

  Future<Project?> _getProject() async {
    if (_studentAccount?.project != null) {
      try {
        _studentProject = await getProject(_studentAccount!.project!);
        return _studentProject;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<Student?> _getStudent() async {
    await _getUser();
    if (_user != null) {
      if (_user!.groups.isNotEmpty && _user!.groups.first == 2) {
        try {
          _studentAccount = await getStudent(_user?.id);
          // If getStudent returns null, it means student is not approved
          if (_studentAccount == null) {
            return null;
          }
          return _studentAccount;
        } catch (e) {
          // If there's an error, it might be because student is not approved
          return null;
        }
      }
    }
    return null;
  }

  Future<User> updateUserFirstName(int id, String firstName) async {
    return await patchUser(id, firstName, null, null, null);
  }

  Future<User> updateUserLastName(int id, String lastName) async {
    return await patchUser(id, null, lastName, null, null);
  }

  Future<String> changePassword(String pastPassword, String newPassword) async {
    return await patchPassword(pastPassword, newPassword);
  }
} 
