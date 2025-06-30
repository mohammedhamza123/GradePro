/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

TeacherList teacherListFromJson(String str) => TeacherList.fromJson(json.decode(str));

String teacherListToJson(TeacherList data) => json.encode(data.toJson());

class TeacherList {
    TeacherList({
        required this.teacher,
    });

    List<Teacher> teacher;

    factory TeacherList.fromJson(Map<dynamic, dynamic> json) => TeacherList(
        teacher: List<Teacher>.from(json["datum"].map((x) => Teacher.fromJson(x))),
    );

    Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(teacher.map((x) => x.toJson())),
    };
}

class Teacher {
    Teacher({
        required this.phoneNumber,
        required this.id,
        required this.user,
        required this.isExaminer,
    });

    int phoneNumber;
    int id;
    int user;
    bool isExaminer;

    factory Teacher.fromJson(Map<dynamic, dynamic> json) => Teacher(
        phoneNumber: json["phoneNumber"],
        id: json["id"],
        user: json["user"],
        isExaminer: json["isExaminer"],
    );

    Map<dynamic, dynamic> toJson() => {
        "phoneNumber": phoneNumber,
        "id": id,
        "user": user,
        "isExaminer": isExaminer,
    };
}
