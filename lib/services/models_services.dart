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

Future<User> getMyAccount() async {
  http.Response response = await services.get(MYACCOUNT, null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return User.fromJson(jsonDecode(body).first);
}

Future<Student?> getStudent(int? id) async {
  http.Response response = await services.get(STUDENT, {"user": "$id"});
  if (response.statusCode == 403) {
    // Student is not approved yet
    return null;
  }
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return Student.fromJson(jsonDecode(body)["datum"].first);
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
