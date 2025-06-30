/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

ImportantDateList importantDateListFromJson(String str) => ImportantDateList.fromJson(json.decode(str));

String importantDateListToJson(ImportantDateList data) => json.encode(data.toJson());

class ImportantDateList {
    ImportantDateList({
        required this.importantDate,
    });

    List<ImportantDate> importantDate;

    factory ImportantDateList.fromJson(Map<dynamic, dynamic> json) => ImportantDateList(
        importantDate: List<ImportantDate>.from(json["datum"].map((x) => ImportantDate.fromJson(x))),
    );

    Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(importantDate.map((x) => x.toJson())),
    };
}

class ImportantDate {
    ImportantDate({
        required this.date,
        required this.dateType,
        required this.teacher,
        required this.student,
        required this.project,
        required this.id,
    });

    DateTime date;
    String dateType;
    int teacher;
    int student;
    int project;
    int id;

    factory ImportantDate.fromJson(Map<dynamic, dynamic> json) => ImportantDate(
        date: DateTime.parse(json["date"]),
        dateType: json["date_type"],
        teacher: json["teacher"],
        student: json["student"],
        project: json["project"],
        id: json["id"],
    );

    Map<dynamic, dynamic> toJson() => {
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "date_type": dateType,
        "teacher": teacher,
        "student": student,
        "project": project,
        "id": id,
    };
}
