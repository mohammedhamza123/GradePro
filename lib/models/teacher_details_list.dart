/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

import 'package:gradpro/models/user_list.dart';

TeacherDetailsList teacherDetailsListFromJson(String str) =>
    TeacherDetailsList.fromJson(json.decode(str));

String teacherDetailsListToJson(TeacherDetailsList data) =>
    json.encode(data.toJson());

class TeacherDetailsList {
  TeacherDetailsList({
    required this.teacher,
  });

  List<TeacherDetail> teacher;

  factory TeacherDetailsList.fromJson(Map<dynamic, dynamic> json) =>
      TeacherDetailsList(
        teacher: List<TeacherDetail>.from(
            json["datum"].map((x) => TeacherDetail.fromJson(x))),
      );

  Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(teacher.map((x) => x.toJson())),
      };
}

class TeacherDetail {
  TeacherDetail({
    required this.phoneNumber,
    required this.id,
    required this.user,
    required this.isExaminer,
  });

  int phoneNumber;
  int id;
  User user;
  bool isExaminer;

  factory TeacherDetail.fromJson(Map<dynamic, dynamic> json) => TeacherDetail(
      phoneNumber: json["phoneNumber"],
      id: json["id"],
      user: User.fromJson(json["user"]),
      isExaminer: json["isExaminer"]);

  Map<dynamic, dynamic> toJson() => {
        "phoneNumber": phoneNumber,
        "id": id,
        "user": user.toJson(),
        "isExaminer": isExaminer,
      };
}
//
// class User {
//     User({
//         required this.lastName,
//         required this.groups,
//         required this.id,
//         required this.firstName,
//         required this.username,
//     });
//
//     String lastName;
//     List<int> groups;
//     int id;
//     String firstName;
//     String username;
//
//     factory User.fromJson(Map<dynamic, dynamic> json) => User(
//         lastName: json["last_name"],
//         groups: List<int>.from(json["groups"].map((x) => x)),
//         id: json["id"],
//         firstName: json["first_name"],
//         username: json["username"],
//     );
//
//     Map<dynamic, dynamic> toJson() => {
//         "last_name": lastName,
//         "groups": List<dynamic>.from(groups.map((x) => x)),
//         "id": id,
//         "first_name": firstName,
//         "username": username,
//     };
// }
