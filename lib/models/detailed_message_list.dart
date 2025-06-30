/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

import 'package:gradpro/models/user_list.dart';

DetailedMessageList detailedMessageListFromJson(String str) => DetailedMessageList.fromJson(json.decode(str));

String detailedMessageListToJson(DetailedMessageList data) => json.encode(data.toJson());

class DetailedMessageList {
    DetailedMessageList({
        required this.detailedMessage,
    });

    List<DetailedMessage> detailedMessage;

    factory DetailedMessageList.fromJson(Map<dynamic, dynamic> json) => DetailedMessageList(
        detailedMessage: List<DetailedMessage>.from(json["datum"].map((x) => DetailedMessage.fromJson(x))),
    );

    Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(detailedMessage.map((x) => x.toJson())),
    };
}

class DetailedMessage {
    DetailedMessage({
        required this.timeSent,
        required this.sender,
        required this.channel,
        required this.context,
        required this.id,
    });

    DateTime timeSent;
    User sender;
    int channel;
    String context;
    int id;

    factory DetailedMessage.fromJson(Map<dynamic, dynamic> json) => DetailedMessage(
        timeSent: DateTime.parse(json["time_sent"]),
        sender: User.fromJson(json["sender"]),
        channel: json["Channel"],
        context: json["context"],
        id: json["id"],
    );

    Map<dynamic, dynamic> toJson() => {
        "time_sent": timeSent.toIso8601String(),
        "sender": sender.toJson(),
        "Channel": channel,
        "context": context,
        "id": id,
    };
}
//
// class Sender {
//     Sender({
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
//     factory Sender.fromJson(Map<dynamic, dynamic> json) => Sender(
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
