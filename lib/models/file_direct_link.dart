/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

FileDirectLink fileDirectLinkFromJson(String str) => FileDirectLink.fromJson(json.decode(str));

String fileDirectLinkToJson(FileDirectLink data) => json.encode(data.toJson());

class FileDirectLink {
    FileDirectLink({
        required this.data,
        required this.status,
    });

    List<DirectLinkData> data;
    String status;

    factory FileDirectLink.fromJson(Map<dynamic, dynamic> json) => FileDirectLink(
        data: List<DirectLinkData>.from(json["data"].map((x) => DirectLinkData.fromJson(x))),
        status: json["status"],
    );

    Map<dynamic, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
    };
}

class DirectLinkData {
    DirectLinkData({
        required this.directLink,
        required this.expireTime,
        required this.isReqLink,
        required this.auth,
        required this.sourceIpsAllowed,
        required this.domainsAllowed,
        required this.id,
    });

    String directLink;
    int expireTime;
    bool isReqLink;
    List<dynamic> auth;
    List<dynamic> sourceIpsAllowed;
    List<dynamic> domainsAllowed;
    String id;

    factory DirectLinkData.fromJson(Map<dynamic, dynamic> json) => DirectLinkData(
        directLink: json["directLink"],
        expireTime: json["expireTime"],
        isReqLink: json["isReqLink"],
        auth: List<dynamic>.from(json["auth"].map((x) => x)),
        sourceIpsAllowed: List<dynamic>.from(json["sourceIpsAllowed"].map((x) => x)),
        domainsAllowed: List<dynamic>.from(json["domainsAllowed"].map((x) => x)),
        id: json["id"],
    );

    Map<dynamic, dynamic> toJson() => {
        "directLink": directLink,
        "expireTime": expireTime,
        "isReqLink": isReqLink,
        "auth": List<dynamic>.from(auth.map((x) => x)),
        "sourceIpsAllowed": List<dynamic>.from(sourceIpsAllowed.map((x) => x)),
        "domainsAllowed": List<dynamic>.from(domainsAllowed.map((x) => x)),
        "id": id,
    };
}
