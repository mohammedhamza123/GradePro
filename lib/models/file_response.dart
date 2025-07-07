/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

FileResponse fileResponseFromJson(String str) => FileResponse.fromJson(json.decode(str));

String fileResponseToJson(FileResponse data) => json.encode(data.toJson());

class FileResponse {
    FileResponse({
        required this.data,
        required this.status,
    });

    Data data;
    String status;

    factory FileResponse.fromJson(Map<dynamic, dynamic> json) => FileResponse(
        data: Data.fromJson(json["data"]),
        status: json["status"],
    );

    Map<dynamic, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
    };
}

class Data {
    Data({
        this.fileName,
        this.parentFolder,
        this.code,
        this.downloadPage,
        this.fileId,
        this.md5,
    });

    String? fileName;
    String? parentFolder;
    String? code;
    String? downloadPage;
    String? fileId;
    String? md5;

    factory Data.fromJson(Map<dynamic, dynamic> json) => Data(
        fileName: json["fileName"],
        parentFolder: json["parentFolder"],
        code: json["code"],
        downloadPage: json["downloadPage"] ?? json["downloadPage"] ?? json["downloadPage"] ?? "",
        fileId: json["fileId"] ?? json["id"],
        md5: json["md5"],
    );

    Map<dynamic, dynamic> toJson() => {
        "fileName": fileName,
        "parentFolder": parentFolder,
        "code": code,
        "downloadPage": downloadPage,
        "fileId": fileId,
        "md5": md5,
    };
}
