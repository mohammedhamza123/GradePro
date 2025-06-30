/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

MessageList messageListFromJson(String str) => MessageList.fromJson(json.decode(str));

String messageListToJson(MessageList data) => json.encode(data.toJson());

class MessageList {
    MessageList({
        required this.message,
    });

    List<Message> message;

    factory MessageList.fromJson(Map<dynamic, dynamic> json) => MessageList(
        message: List<Message>.from(json["datum"].map((x) => Message.fromJson(x))),
    );

    Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(message.map((x) => x.toJson())),
    };
}

class Message {
    Message({
        required this.timeSent,
        required this.sender,
        required this.channel,
        required this.context,
        required this.id,
    });

    DateTime timeSent;
    int sender;
    int channel;
    String context;
    int id;

    factory Message.fromJson(Map<dynamic, dynamic> json) => Message(
        timeSent: DateTime.parse(json["time_sent"]),
        sender: json["sender"],
        channel: json["Channel"],
        context: json["context"],
        id: json["id"],
    );

    Map<String , dynamic> toJson() => {
        "time_sent": timeSent.toIso8601String(),
        "sender": sender,
        "Channel": channel,
        "context": context,
        "id": id,
    };
}
