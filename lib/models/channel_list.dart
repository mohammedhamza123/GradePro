/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

ChannelList channelListFromJson(String str) => ChannelList.fromJson(json.decode(str));

String channelListToJson(ChannelList data) => json.encode(data.toJson());

class ChannelList {
    ChannelList({
        required this.channel,
    });

    List<Channel> channel;

    factory ChannelList.fromJson(Map<dynamic, dynamic> json) => ChannelList(
        channel: List<Channel>.from(json["datum"].map((x) => Channel.fromJson(x))),
    );

    Map<dynamic, dynamic> toJson() => {
        "datum": List<dynamic>.from(channel.map((x) => x.toJson())),
    };
}

class Channel {
    Channel({
        required this.members,
        required this.project,
        required this.id,
    });

    List<int> members;
    int project;
    int id;

    factory Channel.fromJson(Map<dynamic, dynamic> json) => Channel(
        members: List<int>.from(json["members"].map((x) => x)),
        project: json["project"],
        id: json["id"],
    );

    Map<dynamic, dynamic> toJson() => {
        "members": List<dynamic>.from(members.map((x) => x)),
        "project": project,
        "id": id,
    };
}
