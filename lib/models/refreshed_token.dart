/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

RefreshedToken refreshedTokenFromJson(String str) => RefreshedToken.fromJson(json.decode(str));

String refreshedTokenToJson(RefreshedToken data) => json.encode(data.toJson());

class RefreshedToken {
    RefreshedToken({
        required this.access,
    });

    String access;

    factory RefreshedToken.fromJson(Map<dynamic, dynamic> json) => RefreshedToken(
        access: json["access"],
    );

    Map<dynamic, dynamic> toJson() => {
        "access": access,
    };
}
