/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

ImageResponse imageResponseFromJson(String str) => ImageResponse.fromJson(json.decode(str));

String imageResponseToJson(ImageResponse data) => json.encode(data.toJson());

class ImageResponse {
    ImageResponse({
        required this.data,
        required this.success,
        required this.status,
    });

    Data data;
    bool success;
    int status;

    factory ImageResponse.fromJson(Map<dynamic, dynamic> json) => ImageResponse(
        data: Data.fromJson(json["data"]),
        success: json["success"],
        status: json["status"],
    );

    Map<dynamic, dynamic> toJson() => {
        "data": data.toJson(),
        "success": success,
        "status": status,
    };
}

class Data {
    Data({
        required this.displayUrl,
        required this.image,
        required this.thumb,
        required this.deleteUrl,
        required this.title,
        required this.urlViewer,
        required this.url,
        required this.size,
        required this.width,
        required this.expiration,
        required this.id,
        required this.time,
        required this.height,
    });

    String displayUrl;
    Image image;
    Image thumb;
    String deleteUrl;
    String title;
    String urlViewer;
    String url;
    int size;
    int width;
    int expiration;
    String id;
    int time;
    int height;

    factory Data.fromJson(Map<dynamic, dynamic> json) => Data(
        displayUrl: json["display_url"],
        image: Image.fromJson(json["image"]),
        thumb: Image.fromJson(json["thumb"]),
        deleteUrl: json["delete_url"],
        title: json["title"],
        urlViewer: json["url_viewer"],
        url: json["url"],
        size: json["size"],
        width: json["width"],
        expiration: json["expiration"],
        id: json["id"],
        time: json["time"],
        height: json["height"],
    );

    Map<dynamic, dynamic> toJson() => {
        "display_url": displayUrl,
        "image": image.toJson(),
        "thumb": thumb.toJson(),
        "delete_url": deleteUrl,
        "title": title,
        "url_viewer": urlViewer,
        "url": url,
        "size": size,
        "width": width,
        "expiration": expiration,
        "id": id,
        "time": time,
        "height": height,
    };
}

class Image {
    Image({
        required this.extension,
        required this.filename,
        required this.mime,
        required this.name,
        required this.url,
    });

    String extension;
    String filename;
    String mime;
    String name;
    String url;

    factory Image.fromJson(Map<dynamic, dynamic> json) => Image(
        extension: json["extension"],
        filename: json["filename"],
        mime: json["mime"],
        name: json["name"],
        url: json["url"],
    );

    Map<dynamic, dynamic> toJson() => {
        "extension": extension,
        "filename": filename,
        "mime": mime,
        "name": name,
        "url": url,
    };
}
