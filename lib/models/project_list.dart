/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

ProjectList projectListFromJson(String str) =>
    ProjectList.fromJson(json.decode(str));

String projectListToJson(ProjectList data) => json.encode(data.toJson());

class ProjectList {
  ProjectList({
    required this.project,
  });

  List<Project> project;

  factory ProjectList.fromJson(Map<dynamic, dynamic> json) => ProjectList(
        project:
            List<Project>.from(json["datum"].map((x) => Project.fromJson(x))),
      );

  Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(project.map((x) => x.toJson())),
      };
}

class Project {
  Project({
    required this.image,
    required this.progression,
    required this.id,
    required this.title,
    required this.mainSuggestion,
    required this.deliveryDate,
    required this.teacher,
    this.firstGrading,
    this.secondGrading,
    this.teacherGrading,
  });

  String image;
  double progression;
  int id;
  int? mainSuggestion;
  int? teacher;
  String title;
  String? deliveryDate;
  String? firstGrading;
  String? secondGrading;
  String? teacherGrading;

  factory Project.fromJson(Map<dynamic, dynamic> json) => Project(
        image: json["image"],
        progression: json["progression"],
        id: json["id"],
        title: json["title"],
        deliveryDate: json["delivery_date"],
        mainSuggestion: json["main_suggestion"],
        teacher: json["teacher"],
        firstGrading: json["first_grading"],
        secondGrading: json["second_grading"],
        teacherGrading: json["teacher_grading"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "progression": progression,
        "id": id,
        "title": title,
        "main_suggestion": mainSuggestion,
        "delivery_date": deliveryDate,
        "teacher": teacher,
        "first_grading": firstGrading,
        "second_grading": secondGrading,
        "teacher_grading": teacherGrading
      };
}
