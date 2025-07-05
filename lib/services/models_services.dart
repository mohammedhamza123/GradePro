import 'package:gradpro/models/channel_list.dart';
import 'package:gradpro/models/detailed_message_list.dart';
import 'package:gradpro/models/file_direct_link.dart';
import 'package:gradpro/models/file_response.dart';
import 'package:gradpro/models/image_response.dart';
import 'package:gradpro/models/important_date_list.dart';
import 'package:gradpro/models/message_list.dart';
import 'package:gradpro/models/new_token.dart';
import 'package:gradpro/models/project_details_list.dart';
import 'package:gradpro/models/project_list.dart';
import 'package:gradpro/models/refreshed_token.dart';
import 'package:gradpro/models/requirement_list.dart';
import 'package:gradpro/models/student_details_list.dart';
import 'package:gradpro/models/student_list.dart';
import 'package:gradpro/models/suggestion_list.dart';
import 'package:gradpro/models/teacher_details_list.dart';
import 'package:gradpro/models/teacher_list.dart';
import 'package:gradpro/models/user_list.dart';
import 'package:gradpro/services/endpoints.dart';
import 'package:gradpro/services/internet_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show base64Url;

String responseDecoder(http.Response response) {
  List<int> bodyBytes = response.bodyBytes;
  String decodedString = utf8.decode(bodyBytes);
  return decodedString;
}

final InternetService services = InternetService();

Future<ImportantDateList> getImportantDatesList() async {
  http.Response response = await services.get(IMPORTANTDATE, null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return importantDateListFromJson(body);
}

Future<SuggestionList> getSuggestionList() async {
  http.Response response = await services.get(SUGGESTION, null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return suggestionListFromJson(body);
}

Future<Suggestion> getSuggestion(int id) async {
  http.Response response = await services.get(SUGGESTION, {"id": "$id"});
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return suggestionListFromJson(body).suggestion.first;
}

Future<ProjectList> getProjectList() async {
  http.Response response = await services.get(PROJECT, null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return projectListFromJson(body);
}

Future<User> getMyAccount([String? expectedUsername]) async {
  print('DEBUG: getMyAccount called with expected username: $expectedUsername');
  http.Response response = await services.get(MYACCOUNT, null);
  print('DEBUG: getMyAccount response status: ${response.statusCode}');
  print('DEBUG: getMyAccount response body: ${response.body}');
  
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  
  final jsonData = jsonDecode(body);
  print('DEBUG: getMyAccount jsonData: $jsonData');
  
  // Handle the case where API returns a list of users
  if (jsonData is Map && jsonData.containsKey('datum')) {
    final usersList = jsonData['datum'] as List;
    print('DEBUG: getMyAccount usersList length: ${usersList.length}');
    
    if (usersList.isNotEmpty) {
      User? foundUser;
      
      // Try to find user by expected username
      if (expectedUsername != null) {
        print('DEBUG: getMyAccount searching for username: $expectedUsername');
        for (var userData in usersList) {
          if (userData['username'] == expectedUsername) {
            foundUser = User.fromJson(userData);
            print('DEBUG: getMyAccount found user by username: ID: ${foundUser.id}, Username: ${foundUser.username}, Groups: ${foundUser.groups}');
            break;
          }
        }
      }
      
      if (foundUser == null) {
        // Try to get username from token if not provided
        String? tokenUsername = expectedUsername;
        if (tokenUsername == null) {
          tokenUsername = await _decodeUsernameFromToken();
          print('DEBUG: getMyAccount got username from token: $tokenUsername');
        }
        
        // Try to find user by token username
        if (tokenUsername != null) {
          print('DEBUG: getMyAccount searching for token username: $tokenUsername');
          for (var userData in usersList) {
            // Check if tokenUsername is a number (user_id) or string (username)
            if (int.tryParse(tokenUsername) != null) {
              // tokenUsername is a number, search by user_id
              if (userData['id'].toString() == tokenUsername) {
                foundUser = User.fromJson(userData);
                print('DEBUG: getMyAccount found user by user_id: ID: ${foundUser.id}, Username: ${foundUser.username}, Groups: ${foundUser.groups}');
                break;
              }
            } else {
              // tokenUsername is a string, search by username
              if (userData['username'] == tokenUsername) {
                foundUser = User.fromJson(userData);
                print('DEBUG: getMyAccount found user by username: ID: ${foundUser.id}, Username: ${foundUser.username}, Groups: ${foundUser.groups}');
                break;
              }
            }
          }
        }
        
        // If still not found, fallback to first user
        if (foundUser == null) {
          final userData = usersList.first;
          print('DEBUG: getMyAccount using first user (fallback): $userData');
          foundUser = User.fromJson(userData);
          print('DEBUG: getMyAccount parsed user: ID: ${foundUser.id}, Username: ${foundUser.username}, Groups: ${foundUser.groups}');
        }
      }
      
      return foundUser!;
    } else {
      throw Exception('No users found');
    }
  } else if (jsonData is List && jsonData.isNotEmpty) {
    // Handle direct list response
    final userData = jsonData.first;
    print('DEBUG: getMyAccount first user data (list): $userData');
    final user = User.fromJson(userData);
    print('DEBUG: getMyAccount parsed user (list): ID: ${user.id}, Username: ${user.username}, Groups: ${user.groups}');
    return user;
  } else {
    throw Exception('Invalid user data structure');
  }
}

// Temporary helper function to get current username from token
Future<String?> _getCurrentUsernameFromToken() async {
  try {
    // This is a hack - in a real app, the backend should decode the token
    // and return the current user's information
    final response = await services.get('/api/token/verify/', null);
    print('DEBUG: Token verify response status: ${response.statusCode}');
    print('DEBUG: Token verify response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['username'];
    }
  } catch (e) {
    print('DEBUG: Error getting username from token: $e');
  }
  return null;
}

// Temporary helper function to decode username from JWT token
Future<String?> _decodeUsernameFromToken() async {
  try {
    // Get the current token
    final token = services.getToken();
    if (token == null) {
      print('DEBUG: No token available for decoding');
      return null;
    }
    
    print('DEBUG: Attempting to decode token: ${token.substring(0, 50)}...');
    
    // JWT tokens have 3 parts separated by dots
    final parts = token.split('.');
    if (parts.length != 3) {
      print('DEBUG: Invalid JWT token format');
      return null;
    }
    
    // Decode the payload (second part)
    final payload = parts[1];
    
    // Add padding if needed (only if not already padded)
    String paddedPayload = payload;
    if (payload.length % 4 != 0) {
      paddedPayload = payload + '=' * (4 - payload.length % 4);
    }
    
    // Decode base64
    final decodedBytes = base64Url.decode(paddedPayload);
    final decodedString = utf8.decode(decodedBytes);
    final payloadData = jsonDecode(decodedString);
    
    print('DEBUG: Decoded token payload: $payloadData');
    
    // Extract username from payload
    final username = payloadData['username'] ?? payloadData['user_id'];
    print('DEBUG: Extracted username from token: $username');
    
    return username?.toString();
  } catch (e) {
    print('DEBUG: Error decoding token: $e');
    return null;
  }
}

Future<Student?> getStudent(int? id) async {
  print('DEBUG: getStudent called for user $id');
  http.Response response = await services.get(STUDENT, {"user": "$id"});
  print('DEBUG: getStudent response status: ${response.statusCode}');
  print('DEBUG: getStudent response body: ${response.body}');
  
  if (response.statusCode == 403) {
    print('DEBUG: Student not approved (403)');
    // Student is not approved yet - throw exception instead of returning null
    throw Exception('Student not approved yet');
  }
  
  if (response.statusCode != 200) {
    print('DEBUG: Student error status: ${response.statusCode}');
    throw Exception('${response.statusCode}:${response.body}');
  }
  
  final body = responseDecoder(response);
  final data = jsonDecode(body);
  print('DEBUG: Student data: $data');
  
  if (data['datum'] == null || data['datum'].isEmpty) {
    print('DEBUG: No student data found');
    throw Exception('Student not approved yet');
  }
  
  print('DEBUG: Student approved, returning student data');
  print('DEBUG: Student ID: ${data["datum"].first["id"]}');
  print('DEBUG: Student user: ${data["datum"].first["user"]}');
  print('DEBUG: Student serialNumber: ${data["datum"].first["serialNumber"]}');
  return Student.fromJson(data["datum"].first);
}

Future<StudentDetailsList> getStudentDetailsList() async {
  http.Response response = await services.get(STUDENTDETAILS, null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return studentDetailsListFromJson(body);
}

Future<TeacherDetailsList> getTeacherDetailsList() async {
  http.Response response = await services.get(TEACHERDETAILS, null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return teacherDetailsListFromJson(body);
}

Future<void> delStudent(int id) async {
  http.Response response = await services.delete("$USER$id/");
  if (response.statusCode != 204) {
    throw Exception('${response.statusCode}:${response.body}');
  }
}

Future<void> delTeacher(int id) async {
  http.Response response = await services.delete("$TEACHER$id/");
  if (response.statusCode != 204) {
    throw Exception('${response.statusCode}:${response.body}');
  }
}

Future<Project> getProject(int id) async {
  http.Response response = await services.get("$PROJECT$id/", null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Project.fromJson(jsonDecode(body));
}

Future<ProjectDetailsList> getProjectDetailsList() async {
  http.Response response = await services.get(PROJECTDETAILS, null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return projectDetailsListFromJson(body);
}

Future<Project> postProject(Project project) async {
  http.Response response = await services.post(PROJECT, project.toJson());
  final body = responseDecoder(response);
  if (response.statusCode != 201) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Project.fromJson(jsonDecode(body));
}

Future<Project> patchProject(
    {required int id,
    required int? teacher,
    String? title,
    String? image,
    required double? progression,
    required String? deliveryDate,
    required int? mainSuggestion,
    String? firstGrading,
    String? secondGrading,
    String? teacherGrading}) async {
  Map<String, dynamic> request = <String, dynamic>{};
  if (teacher != 0) {
    request["teacher"] = teacher;
  }
  if (progression != null) {
    request["progression"] = progression;
  }
  if (title != null || title != "") {
    request["title"] = title;
  }
  if (mainSuggestion != 0) {
    request["main_suggestion"] = mainSuggestion;
  }
  if (image != null || image != "") {
    request["image"] = image;
  }
  if (deliveryDate != "") {
    request["delivery_date"] = deliveryDate;
  }
  if (firstGrading != null) {
    request["first_grading"] = firstGrading;
  }
  if (secondGrading != null) {
    request["second_grading"] = firstGrading;
  }
  if (teacherGrading != null) {
    request["teacher_grading"] = teacherGrading;
  }
  http.Response response = await services.patch("$PROJECT$id/", request);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Project.fromJson(jsonDecode(body));
}

Future<void> delProject(int id) async {
  http.Response response = await services.delete("$PROJECT$id/");
  if (response.statusCode != 204) {
    throw Exception('${response.statusCode}:${response.body}');
  }
}

Future<Student> patchStudent(
    int id, int? phoneNumber, int? project, int? serialNumber) async {
  Map<String, dynamic> request = <String, dynamic>{};
  if (phoneNumber != null) {
    request["phoneNumber"] = phoneNumber;
  }
  if (project != null) {
    request["project"] = project;
  }
  if (serialNumber != null) {
    request["serialNumber"] = serialNumber;
  }
  
  http.Response response = await services.patch("$STUDENT$id/", request);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Student.fromJson(jsonDecode(body));
}

Future<RequirementList> getRequirementList() async {
  http.Response response = await services.get(REQUIREMENT, null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return requirementListFromJson(body);
}

Future<Requirement> postRequirement(int suggestion, String name) async {
  http.Response response = await services
      .post(REQUIREMENT, {"suggestion": suggestion, "name": name});
  final body = responseDecoder(response);
  if (response.statusCode != 201) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Requirement.fromJson(jsonDecode(body));
}

Future<Suggestion> postSuggestion(Suggestion suggestionItem) async {
  http.Response response = await services.post(SUGGESTION, suggestionItem.toJson());
  final body = responseDecoder(response);
  if (response.statusCode != 201) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Suggestion.fromJson(jsonDecode(body));
}

Future<Suggestion> patchSuggestion({
  required int id,
  required String? title,
  required String? image,
  required String? status,
}) async {
  Map<String, dynamic> request = <String, dynamic>{};
  if (title != null || title != "") {
    request["title"] = title;
  }
  if (image != null || image != "") {
    request["image"] = image;
  }
  if (status == "w" || status == "a" || status == "r") {
    request["status"] = status;
  }
  http.Response response = await services.patch("$SUGGESTION$id/", request);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Suggestion.fromJson(jsonDecode(body));
}

Future<void> delSuggestion(int id) async {
  http.Response response = await services.delete("$SUGGESTION$id/");
  if (response.statusCode != 204) {
    throw Exception('${response.statusCode}:${response.body}');
  }
}

Future<void> delRequirement(int id) async {
  http.Response response = await services.delete("$REQUIREMENT$id/");
  if (response.statusCode != 204) {
    throw Exception('${response.statusCode}:${response.body}');
  }
}

Future<Requirement> patchRequirement(
    int id, String? name, String? status, int? suggestionId) async {
  Map<String, dynamic> request = <String, dynamic>{};
  if (name != null && name.isNotEmpty) {
    request["name"] = name;
  }
  if (status != null) {
    request["status"] = status;
  }
  if (suggestionId != null) {
    request["suggestion"] = suggestionId;
  }
  http.Response response = await services.patch("$REQUIREMENT$id/", request);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Requirement.fromJson(jsonDecode(body));
}

Future<User?> registerUser(Map<String, dynamic> user) async {
  // For registration, we don't need authentication, so we'll make a direct call
  final url = Uri.parse("https://easy0123.pythonanywhere.com$REGISTER");
  print("Attempting registration to: $url");
  print("User data: ${jsonEncode(user)}");
  
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(user),
    encoding: Encoding.getByName("utf-8"),
  ).timeout(const Duration(seconds: 15));
  
  print("Registration response status: ${response.statusCode}");
  print("Registration response body: ${response.body}");
  final body = responseDecoder(response);
  if (response.statusCode != 201) {
    // تحسين رسائل الخطأ
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map<String, dynamic>) {
        if (errorData.containsKey('email')) {
          throw Exception('البريد الإلكتروني مستخدم بالفعل');
        } else if (errorData.containsKey('username')) {
          throw Exception('اسم المستخدم مستخدم بالفعل');
        } else {
          // عرض أول خطأ موجود
          final firstError = errorData.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          } else {
            throw Exception(firstError.toString());
          }
        }
      }
    } catch (e) {
      // إذا فشل في تحليل JSON، استخدم الرسالة الأصلية
      throw Exception(response.body);
    }
  }
  return User.fromJson(json.decode(body));
}

Future<User> patchUser(int id, String? firstName, String? lastName,
    String? userName, String? email) async {
  Map<String, dynamic> request = <String, dynamic>{};
  if (firstName != null && firstName.isNotEmpty) {
    request["first_name"] = firstName;
  }
  if (lastName != null && lastName.isNotEmpty) {
    request["last_name"] = lastName;
  }
  if (userName != null && userName.isNotEmpty) {
    request["username"] = userName;
  }
  http.Response response = await services.patch("$USER$id/", request);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return User.fromJson(jsonDecode(body));
}

Future<String> patchPassword(String oldPass, String newPass) async {
  Map<String, dynamic> request = <String, dynamic>{};
  request["old_password"] = oldPass;
  request["new_password"] = newPass;
  http.Response response = await services.patch(ChangePassword, request);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return body;
}

Future<Teacher> getTeacher(int id) async {
  http.Response response = await services.get(TEACHER, {"user": "$id"});
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return teacherListFromJson(body).teacher.first;
}

Future<Student> patchTeacher(int id, int? phoneNumber, bool? isExaminer) async {
  Map<String, dynamic> request = <String, dynamic>{};
  if (phoneNumber != null) {
    request["phoneNumber"] = phoneNumber;
  }
  if (isExaminer != null) {
    request["isExaminer"] = isExaminer;
  }

  http.Response response = await services.patch("$TEACHER$id/", request);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Student.fromJson(jsonDecode(body));
}

Future<DetailedMessageList> getMessageList(int? channel) async {
  http.Response response = await services.get(
      DETAILEDMESSAGES, channel != null ? {"channel": "$channel"} : null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return detailedMessageListFromJson(body);
}

Future<Message> postMessage(Message message) async {
  http.Response response = await services.post(MESSAGES, message.toJson());
  final body = responseDecoder(response);
  if (response.statusCode != 201) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Message.fromJson(jsonDecode(body));
}

Future<ChannelList> getChannelList(int? project) async {
  if (project != null) {
    final response = await services.get(CHANNEL, {"project": "$project"});
    final body = responseDecoder(response);
    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}:${response.body}');
    }
    return channelListFromJson(body);
  }
  final response = await services.get(CHANNEL, null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return channelListFromJson(body);
}

Future<Channel> getChannel(int id) async {
  final response = await services.get("$CHANNEL$id", null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Channel.fromJson(jsonDecode(body));
}

Future<String> getApiKey() async {
  final response = await services.get(APIKEY, null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  // Assuming the API returns: {"key": "your_api_key"}
  return jsonDecode(body)['key'];
}

// وظائف الموافقة والرفض للطلاب
Future<void> approveStudentAPI(int studentId) async {
  http.Response response = await services.post("$STUDENT$studentId/approve/", {});
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
}

Future<void> rejectStudentAPI(int studentId) async {
  // رفض الطالب وحذفه من قاعدة البيانات
  http.Response response = await services.post("$STUDENT$studentId/reject/", {});
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
}

Future<StudentDetailsList> getPendingStudents() async {
  http.Response response = await services.get("${STUDENT}pending_approval/", null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return studentDetailsListFromJson(body);
}

// التحقق من حالة الطالب
Future<bool> checkStudentApprovalStatus(String username) async {
  try {
    // First, try to get user by username
    final userResponse = await http.get(
      Uri.parse("https://easy0123.pythonanywhere.com$USER?username=$username"),
      headers: {
        "Content-Type": "application/json",
      },
    ).timeout(const Duration(seconds: 10));
    
    if (userResponse.statusCode == 200) {
      final userData = jsonDecode(userResponse.body);
      if (userData.isNotEmpty) {
        final userId = userData[0]['id'];
        
        // Then check student status
        final studentResponse = await http.get(
          Uri.parse("https://easy0123.pythonanywhere.com$STUDENT?user=$userId"),
          headers: {
            "Content-Type": "application/json",
          },
        ).timeout(const Duration(seconds: 10));
        
        if (studentResponse.statusCode == 200) {
          final studentData = jsonDecode(studentResponse.body);
          if (studentData['datum'] != null && studentData['datum'].isNotEmpty) {
            return studentData['datum'][0]['is_approved'] ?? false;
          }
        } else if (studentResponse.statusCode == 403) {
          // Student exists but not approved
          return false;
        }
      }
    }
    
    return false;
  } catch (e) {
    return false;
  }
}
