/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

NewToken newTokenFromJson(String str) => NewToken.fromJson(json.decode(str));

String newTokenToJson(NewToken data) => json.encode(data.toJson());

class NewToken {
    NewToken({
        required this.access,
        required this.refresh,
    });

    String access;
    String refresh;

    factory NewToken.fromJson(Map<dynamic, dynamic> json) => NewToken(
        access: json["access"],
        refresh: json["refresh"],
    );

    Map<dynamic, dynamic> toJson() => {
        "access": access,
        "refresh": refresh,
    };
}
