/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

StudentList studentListFromJson(String str) =>
    StudentList.fromJson(json.decode(str));

String studentListToJson(StudentList data) => json.encode(data.toJson());

class StudentList {
  StudentList({
    required this.student,
  });

  List<Student> student;

  factory StudentList.fromJson(Map<dynamic, dynamic> json) => StudentList(
        student:
            List<Student>.from(json["datum"].map((x) => Student.fromJson(x))),
      );

  Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(student.map((x) => x.toJson())),
      };
}

class Student {
  Student({
    required this.phoneNumber,
    required this.project,
    required this.id,
    required this.user,
    required this.serialNumber,
    this.isApproved,
  });

  int? phoneNumber;
  int? project;
  int? serialNumber;
  int id;
  int user;
  bool? isApproved;

  factory Student.fromJson(Map<dynamic, dynamic> json) => Student(
        phoneNumber: json["phoneNumber"],
        project: json["project"],
        serialNumber: json["serialNumber"],
        id: json["id"],
        user: json["user"],
        isApproved: json["is_approved"],
      );

  Map<dynamic, dynamic> toJson() => {
        "phoneNumber": phoneNumber,
        "project": project,
        "serialNumber": serialNumber,
        "id": id,
        "user": user,
        "is_approved": isApproved,
      };
}
