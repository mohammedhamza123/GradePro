/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

import 'package:gradpro/models/suggestion_list.dart';
import 'package:gradpro/models/teacher_details_list.dart';

ProjectDetailsList projectDetailsListFromJson(String str) =>
    ProjectDetailsList.fromJson(json.decode(str));

String projectDetailsListToJson(ProjectDetailsList data) =>
    json.encode(data.toJson());

class ProjectDetailsList {
  ProjectDetailsList({
    required this.datum,
  });

  List<ProjectDetail> datum;

  factory ProjectDetailsList.fromJson(Map<dynamic, dynamic> json) =>
      ProjectDetailsList(
        datum: List<ProjectDetail>.from(
            json["datum"].map((x) => ProjectDetail.fromJson(x))),
      );

  Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(datum.map((x) => x.toJson())),
      };
}

class ProjectDetail {
  ProjectDetail({
    this.mainSuggestion,
    required this.image,
    this.deliveryDate,
    required this.teacher, // now int?
    required this.progression,
    required this.id,
    required this.title,
    this.supervisorRaw,
    this.examiner1Raw,
    this.examiner2Raw,
    this.headScore,
    this.coordinatorScore,
    this.finalScore,
  });

  Suggestion? mainSuggestion;
  String image;
  DateTime? deliveryDate;
  int? teacher; // changed from TeacherDetail? to int?
  double progression;
  int id;
  String title;
  double? supervisorRaw;    // درجة المشرف من 500
  double? examiner1Raw;     // درجة الممتحن الأول من 500
  double? examiner2Raw;     // درجة الممتحن الثاني من 500
  double? headScore;        // رئيس القسم من 5
  double? coordinatorScore; // المنسق من 5
  double? finalScore;       // الدرجة النهائية المحسوبة من 100

  factory ProjectDetail.fromJson(Map<dynamic, dynamic> json) => ProjectDetail(
        mainSuggestion: json["main_suggestion"] == null
            ? null
            : Suggestion.fromJson(json["main_suggestion"]),
        image: json["image"],
        deliveryDate: json["delivery_date"] == null
            ? null
            : DateTime.parse(json["delivery_date"]),
        teacher: json["teacher"], // just assign the int
        progression: json["progression"]?.toDouble(),
        id: json["id"],
        title: json["title"],
        supervisorRaw: json["supervisor_grade"]?.toDouble(),
        examiner1Raw: json["first_grading"]?.toDouble(),
        examiner2Raw: json["second_grading"]?.toDouble(),
        headScore: json["department_head_grade"]?.toDouble(),
        coordinatorScore: json["coordinator_grade"]?.toDouble(),
        finalScore: json["final_score"]?.toDouble(),
      );

  Map<dynamic, dynamic> toJson() => {
        "main_suggestion": mainSuggestion?.toJson(),
        "image": image,
        "delivery_date":
            deliveryDate != null ? "${deliveryDate!.year.toString().padLeft(4, '0')}-${deliveryDate!.month.toString().padLeft(2, '0')}-${deliveryDate!.day.toString().padLeft(2, '0')}" : null,
        "teacher": teacher, // just output the int
        "progression": progression,
        "id": id,
        "title": title,
        "supervisor_grade": supervisorRaw,
        "first_grading": examiner1Raw,
        "second_grading": examiner2Raw,
        "department_head_grade": headScore,
        "coordinator_grade": coordinatorScore,
        "final_score": finalScore,
      };

  // حساب درجة المشرف النهائية (من 40)
  double? get supervisorScore => supervisorRaw == null ? null : (supervisorRaw! / 500) * 40;
  // حساب درجة الممتحن الأول النهائية (من 25)
  double? get examiner1Score => examiner1Raw == null ? null : (examiner1Raw! / 500) * 25;
  // حساب درجة الممتحن الثاني النهائية (من 25)
  double? get examiner2Score => examiner2Raw == null ? null : (examiner2Raw! / 500) * 25;
  // رئيس القسم (من 5)
  double? get headScoreValue => headScore;
  // المنسق (من 5)
  double? get coordinatorScoreValue => coordinatorScore;

  // الدرجة النهائية من 100 - النظام الجديد
  double? get calculatedFinalScore {
    List<double> availableScores = [];
    
    // إضافة درجة المشرف (من 40)
    if (supervisorScore != null) {
      availableScores.add(supervisorScore!);
    }
    
    // إضافة درجة الممتحن الأول (من 25)
    if (examiner1Score != null) {
      availableScores.add(examiner1Score!);
    }
    
    // إضافة درجة الممتحن الثاني (من 25)
    if (examiner2Score != null) {
      availableScores.add(examiner2Score!);
    }
    
    // إضافة درجة رئيس القسم (من 5)
    if (headScoreValue != null) {
      availableScores.add(headScoreValue!);
    }
    
    // إضافة درجة المنسق (من 5)
    if (coordinatorScoreValue != null) {
      availableScores.add(coordinatorScoreValue!);
    }
    
    // الشرط: يجب أن يكون هناك مشرف + ممتحنين اثنين على الأقل
    bool hasSupervisor = supervisorScore != null;
    bool hasExaminer1 = examiner1Score != null;
    bool hasExaminer2 = examiner2Score != null;
    
    if (!hasSupervisor || (!hasExaminer1 && !hasExaminer2)) {
      return null; // لا يمكن حساب الدرجة النهائية
    }
    
    // حساب الدرجة النهائية: مجموع جميع الدرجات مقسوم على عدد المقيمين × 100
    if (availableScores.isEmpty) {
      return null;
    }
    
    double totalScore = availableScores.reduce((a, b) => a + b);
    double averageScore = totalScore / availableScores.length;
    
    // تحويل الدرجة إلى مقياس من 100
    return (averageScore / 100) * 100; // هذا سيعطي نفس القيمة ولكن من 100
  }

  // دالة للتحقق من اكتمال التقييم
  bool get isEvaluationComplete {
    bool hasSupervisor = supervisorScore != null;
    bool hasExaminer1 = examiner1Score != null;
    bool hasExaminer2 = examiner2Score != null;
    
    // يجب أن يكون هناك مشرف + ممتحنين اثنين على الأقل
    return hasSupervisor && (hasExaminer1 || hasExaminer2);
  }

  // دالة للحصول على عدد المقيمين
  int get numberOfEvaluators {
    int count = 0;
    if (supervisorScore != null) count++;
    if (examiner1Score != null) count++;
    if (examiner2Score != null) count++;
    if (headScoreValue != null) count++;
    if (coordinatorScoreValue != null) count++;
    return count;
  }
}
