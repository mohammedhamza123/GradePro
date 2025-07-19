/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847/yapi-quicktype/documentation

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
    required this.title,
    required this.image,
    required this.progression,
    required this.id,
    this.firstGrading,
    this.secondGrading,
    this.supervisorGrade,
    this.departmentHeadGrade,
    this.coordinatorGrade,
    this.mainSuggestion,
    this.deliveryDate,
    this.teacher,
    this.finalScore,
    this.pdfLink,
    this.pdfExaminer1,
    this.pdfExaminer2,
    this.pdfSupervisor,
    this.pdfHead,
    this.pdfCoordinator,
    this.gradedStatus = "not_graded",
  });

  String title;
  String image;
  double progression;
  int id;
  int? mainSuggestion;
  int? teacher;
  String? deliveryDate;
  double? firstGrading;
  double? secondGrading;
  double? supervisorGrade;
  double? departmentHeadGrade;
  double? coordinatorGrade;
  double? finalScore;
  String? pdfLink;
  String? pdfExaminer1;
  String? pdfExaminer2;
  String? pdfSupervisor;
  String? pdfHead;
  String? pdfCoordinator;
  String gradedStatus; // "not_graded", "partial", "graded"

  factory Project.fromJson(Map<dynamic, dynamic> json) => Project(
        title: json["title"],
        image: json["image"],
        progression: json["progression"]?.toDouble() ?? 0.0,
        id: json["id"],
        deliveryDate: json["delivery_date"],
        mainSuggestion: json["main_suggestion"],
        teacher: json["teacher"],
        firstGrading: json["first_grading"]?.toDouble(),
        secondGrading: json["second_grading"]?.toDouble(),
        supervisorGrade: json["supervisor_grade"]?.toDouble(),
        departmentHeadGrade: json["department_head_grade"]?.toDouble(),
        coordinatorGrade: json["coordinator_grade"]?.toDouble(),
        finalScore: json["final_score"]?.toDouble(),
        pdfLink: json["pdf_link"],
        pdfExaminer1: json["pdf_examiner1"],
        pdfExaminer2: json["pdf_examiner2"],
        pdfSupervisor: json["pdf_supervisor"],
        pdfHead: json["pdf_head"],
        pdfCoordinator: json["pdf_coordinator"],
        gradedStatus: json["graded_status"] ?? "not_graded",
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "image": image,
        "progression": progression,
        "id": id,
        "main_suggestion": mainSuggestion,
        "delivery_date": deliveryDate,
        "teacher": teacher,
        "first_grading": firstGrading,
        "second_grading": secondGrading,
        "supervisor_grade": supervisorGrade,
        "department_head_grade": departmentHeadGrade,
        "coordinator_grade": coordinatorGrade,
        "final_score": finalScore,
        "pdf_link": pdfLink,
        "pdf_examiner1": pdfExaminer1,
        "pdf_examiner2": pdfExaminer2,
        "pdf_supervisor": pdfSupervisor,
        "pdf_head": pdfHead,
        "pdf_coordinator": pdfCoordinator,
        "graded_status": gradedStatus,
      };
}
