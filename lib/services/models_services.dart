import 'package:gradpro/models/channel_list.dart';
import 'package:gradpro/models/detailed_message_list.dart';
import 'package:gradpro/models/important_date_list.dart';
import 'package:gradpro/models/message_list.dart';
import 'package:gradpro/models/project_details_list.dart';
import 'package:gradpro/models/project_list.dart';
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

Future<User> getMyAccount([String? expectedUsername]) async {
  http.Response response = await services.get(MYACCOUNT, null).timeout(
    const Duration(seconds: 15),
    onTimeout: () {
      throw Exception('getMyAccount timeout');
    },
  );

  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }

  final jsonData = jsonDecode(body);

  if (jsonData is Map && jsonData.containsKey('datum')) {
    final usersList = jsonData['datum'] as List;

    if (usersList.isNotEmpty) {
      User? foundUser;

      if (expectedUsername != null) {
        for (var userData in usersList) {
          if (userData['username'] == expectedUsername) {
            foundUser = User.fromJson(userData);
            break;
          }
        }
      }

      if (foundUser == null) {
        String? tokenUsername = expectedUsername;
        tokenUsername = await _decodeUsernameFromToken();

        if (tokenUsername != null) {
          for (var userData in usersList) {
            if (int.tryParse(tokenUsername) != null) {
              if (userData['id'].toString() == tokenUsername) {
                foundUser = User.fromJson(userData);
                break;
              }
            } else {
              if (userData['username'] == tokenUsername) {
                foundUser = User.fromJson(userData);
                break;
              }
            }
          }
        }

        if (foundUser == null) {
          final userData = usersList.first;
          foundUser = User.fromJson(userData);
        }
      }

      return foundUser;
    } else {
      throw Exception('No users found');
    }
  } else if (jsonData is List && jsonData.isNotEmpty) {
    final userData = jsonData.first;
    final user = User.fromJson(userData);
    return user;
  } else {
    throw Exception('Invalid user data structure');
  }
}

Future<String?> _decodeUsernameFromToken() async {
  try {
    final token = services.getToken();
    if (token == null) {
      return null;
    }

    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    final payload = parts[1];

    String paddedPayload = payload;
    if (payload.length % 4 != 0) {
      paddedPayload = payload + '=' * (4 - payload.length % 4);
    }

    final decodedBytes = base64Url.decode(paddedPayload);
    final decodedString = utf8.decode(decodedBytes);
    final payloadData = jsonDecode(decodedString);

    final username = payloadData['username'] ?? payloadData['user_id'];

    return username?.toString();
  } catch (e) {
    return null;
  }
}

Future<Student?> getStudent(int? id) async {
  http.Response response = await services.get(STUDENT, {"user": "$id"}).timeout(
    const Duration(seconds: 15),
    onTimeout: () {
      throw Exception('getStudent timeout');
    },
  );

  if (response.statusCode == 403) {
    throw Exception('Student not approved yet');
  }

  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }

  final body = responseDecoder(response);
  final data = jsonDecode(body);

  if (data['datum'] == null || data['datum'].isEmpty) {
    throw Exception('Student not approved yet');
  }

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
  http.Response response = await services.get("$PROJECT$id/", null).timeout(
    const Duration(seconds: 15),
    onTimeout: () {
      throw Exception('getProject timeout');
    },
  );

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
    double? firstGrading,
    double? secondGrading,
    double? supervisorGrade,
    double? departmentHeadGrade,
    double? coordinatorGrade,
    double? finalScore,
    String? pdfLink,
    String? pdfExaminer1,
    String? pdfExaminer2,
    String? pdfSupervisor,
    String? pdfHead,
    String? pdfCoordinator,
    String? gradedStatus}) async {
  Map<String, dynamic> request = <String, dynamic>{};
  if (teacher != 0) {
    request["teacher"] = teacher;
  }
  if (progression != null) {
    request["progression"] = progression;
  }
  if (title != null && title != "") {
    request["title"] = title;
  }
  if (mainSuggestion != 0) {
    request["main_suggestion"] = mainSuggestion;
  }
  if (image != null && image != "") {
    request["image"] = image;
  }
  if (deliveryDate != null && deliveryDate != "") {
    request["delivery_date"] = deliveryDate;
  }
  if (firstGrading != null) {
    request["first_grading"] = firstGrading;
  }
  if (secondGrading != null) {
    request["second_grading"] = secondGrading;
  }
  if (supervisorGrade != null) {
    request["supervisor_grade"] = supervisorGrade;
  }
  if (departmentHeadGrade != null) {
    request["department_head_grade"] = departmentHeadGrade;
  }
  if (coordinatorGrade != null) {
    request["coordinator_grade"] = coordinatorGrade;
  }
  if (finalScore != null) {
    request["final_score"] = finalScore;
  }
  if (pdfLink != null && pdfLink.isNotEmpty) {
    request["pdf_link"] = pdfLink;
  }
  if (pdfExaminer1 != null && pdfExaminer1.isNotEmpty) {
    request["pdf_examiner1"] = pdfExaminer1;
  }
  if (pdfExaminer2 != null && pdfExaminer2.isNotEmpty) {
    request["pdf_examiner2"] = pdfExaminer2;
  }
  if (pdfSupervisor != null && pdfSupervisor.isNotEmpty) {
    request["pdf_supervisor"] = pdfSupervisor;
  }
  if (pdfHead != null && pdfHead.isNotEmpty) {
    request["pdf_head"] = pdfHead;
  }
  if (pdfCoordinator != null && pdfCoordinator.isNotEmpty) {
    request["pdf_coordinator"] = pdfCoordinator;
  }
  if (gradedStatus != null && gradedStatus.isNotEmpty) {
    request["graded_status"] = gradedStatus;
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
  http.Response response =
      await services.post(SUGGESTION, suggestionItem.toJson());
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
  final url = Uri.parse("https://easy0123.pythonanywhere.com$REGISTER");

  final response = await http
      .post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(user),
        encoding: Encoding.getByName("utf-8"),
      )
      .timeout(const Duration(seconds: 15));

  final body = responseDecoder(response);
  if (response.statusCode != 201) {
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map<String, dynamic>) {
        if (errorData.containsKey('email')) {
          throw Exception('البريد الإلكتروني مستخدم بالفعل');
        } else if (errorData.containsKey('username')) {
          throw Exception('اسم المستخدم مستخدم بالفعل');
        } else {
          final firstError = errorData.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          } else {
            throw Exception(firstError.toString());
          }
        }
      }
    } catch (e) {
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
  return jsonDecode(body)['key'];
}

Future<void> approveStudentAPI(int studentId) async {
  http.Response response =
      await services.post("$STUDENT$studentId/approve/", {});
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
}

Future<void> rejectStudentAPI(int studentId) async {
  http.Response response =
      await services.post("$STUDENT$studentId/reject/", {});
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
}

Future<StudentDetailsList> getPendingStudents() async {
  http.Response response =
      await services.get("${STUDENT}pending_approval/", null);
  final body = responseDecoder(response);
  if (response.statusCode != 200) {
    throw Exception('${response.statusCode}:${response.body}');
  }
  return studentDetailsListFromJson(body);
}

Future<bool> checkStudentApprovalStatus(String username) async {
  try {
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
          return false;
        }
      }
    }

    return false;
  } catch (e) {
    return false;
  }
}
