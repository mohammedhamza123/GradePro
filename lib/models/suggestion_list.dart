/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

SuggestionList suggestionListFromJson(String str) =>
    SuggestionList.fromJson(json.decode(str));

String suggestionListToJson(SuggestionList data) => json.encode(data.toJson());

class SuggestionList {
  SuggestionList({
    required this.suggestion,
  });

  List<Suggestion> suggestion;

  factory SuggestionList.fromJson(Map<dynamic, dynamic> json) => SuggestionList(
        suggestion: List<Suggestion>.from(
            json["datum"].map((x) => Suggestion.fromJson(x))),
      );

  Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(suggestion.map((x) => x.toJson())),
      };
}

class Suggestion {
  Suggestion({
    required this.project,
    required this.id,
    required this.content,
    required this.status,
    required this.title,
    required this.image,
  });

  int project;
  int id;
  String content;
  String status;
  String image;
  String title;

  factory Suggestion.fromJson(Map<dynamic, dynamic> json) => Suggestion(
        project: json["project"],
        id: json["id"],
        content: json["content"],
        status: json["status"],
        image: json["image"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "project": project,
        "id": id,
        "content": content,
        "status": status,
        "image": image,
        "title": title,
      };
}
