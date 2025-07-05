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

  Future<User?> getUserWithUsername(String username) async => await _getUser(username);

  Future<Student?> get student => _getStudent();

  Future<Project?> get project => _getProject();

  Future<User?> _getUser([String? expectedUsername]) async {
    try {
      _user = await getMyAccount(expectedUsername);
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
    print('DEBUG: _getStudent - User: ${_user?.id}, Groups: ${_user?.groups}');
    if (_user != null) {
      if (_user!.groups.isNotEmpty && _user!.groups.first == 2) {
        try {
          print('DEBUG: _getStudent - Calling getStudent with user ID: ${_user?.id}');
          _studentAccount = await getStudent(_user?.id);
          print('DEBUG: _getStudent - Student loaded: ${_studentAccount?.id}');
          return _studentAccount;
        } catch (e) {
          print('DEBUG: _getStudent - Error loading student: $e');
          // If there's an error, it might be because student is not approved
          throw Exception('Student not approved yet');
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
