/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

UserList userListFromJson(String str) => UserList.fromJson(json.decode(str));

String userListToJson(UserList data) => json.encode(data.toJson());

class UserList {
  UserList({
    required this.user,
  });

  List<User> user;

  factory UserList.fromJson(Map<dynamic, dynamic> json) => UserList(
        user: List<User>.from(json["datum"].map((x) => User.fromJson(x))),
      );

  Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(user.map((x) => x.toJson())),
      };
}

class User {
  User({
    required this.lastName,
    required this.id,
    required this.firstName,
    required this.username,
    required this.groups,
    this.email,
  });

  String lastName;
  int id;
  List<dynamic> groups;
  String firstName;
  String username;
  String? email;

  factory User.fromJson(Map<dynamic, dynamic> json) {
    final groups = json["groups"];
    
    // Ensure groups is a List<int>
    List<int> groupsList;
    if (groups is List) {
      groupsList = groups.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    } else if (groups != null) {
      groupsList = [int.tryParse(groups.toString()) ?? 0];
    } else {
      groupsList = [];
    }
    
    return User(
      lastName: json["last_name"],
      id: json["id"],
      firstName: json["first_name"],
      username: json["username"],
      groups: groupsList,
      email: json["email"],
    );
  }

  Map<String, dynamic> toJson() => {
        "last_name": lastName,
        "id": id,
        "first_name": firstName,
        "username": username,
        "groups": groups,
        "email": email,
      };
}
