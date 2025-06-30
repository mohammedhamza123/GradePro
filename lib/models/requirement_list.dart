/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

RequirementList requirementListFromJson(String str) =>
    RequirementList.fromJson(json.decode(str));

String requirementListToJson(RequirementList data) =>
    json.encode(data.toJson());

class RequirementList {
  RequirementList({
    required this.requirement,
  });

  List<Requirement> requirement;

  factory RequirementList.fromJson(Map<dynamic, dynamic> json) =>
      RequirementList(
        requirement: List<Requirement>.from(
            json["datum"].map((x) => Requirement.fromJson(x))),
      );

  Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(requirement.map((x) => x.toJson())),
      };
}

class Requirement {
  Requirement({
    required this.name,
    required this.suggestion,
    required this.id,
    required this.status,
  });

  String name;
  int suggestion;
  int id;
  String status;

  factory Requirement.fromJson(Map<dynamic, dynamic> json) => Requirement(
      name: json["name"],
      suggestion: json["suggestion"],
      id: json["id"],
      status: json["status"]);

  Map<dynamic, dynamic> toJson() =>
      {"name": name, "suggestion": suggestion, "id": id, "status": status};
}
