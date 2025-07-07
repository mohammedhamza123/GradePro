import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gradpro/models/file_direct_link.dart';
import 'package:gradpro/models/file_response.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:convert/convert.dart';

class FileService {
  static final FileService _instance = FileService._internal();

  // ✅ قم بوضع التوكن والمجلد هنا
  static const String _authToken = "kwCRr4gOqLfKWBLBvg75A66raFXOb44j";
  static const String _folderToken = "e52ddd20-4a5a-4092-961a-dcd3958119d8";

  // ✅ عنوان رفع الملفات
  static const String _filesHost = "https://upload.gofile.io/uploadfile";

  factory FileService() => _instance;
  FileService._internal();

  /// ✅ رفع ملف إلى مجلد محدد
  Future<FileResponse?> uploadFile(File file, {String? folderId}) async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        'folderId': folderId ?? _folderToken,
      });

      final response = await dio.post(
        _filesHost,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer $_authToken', // ✅ التوكن في الهيدر
          },
        ),
      );

      print('✅ Status code: ${response.statusCode}');
      print('📦 Response body: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return fileResponseFromJson(jsonEncode(data));
      } else {
        print('❌ Error uploading file: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Dio error: $e');
      return null;
    }
  }

  /// ✅ جلب رابط مباشر لملف أو مجلد
  Future<FileDirectLink?> fetchDirectLink(String fileId) async {
    final url = Uri.parse('https://api.gofile.io/contents/$fileId/directlinks');
    final headers = {'Authorization': 'Bearer $_authToken'};

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        return fileDirectLinkFromJson(response.body);
      } else {
        print('❌ Error fetching direct link: ${response.statusCode}');
        print(response.body);
      }
    } catch (error) {
      print('❌ Exception fetching direct link: $error');
    }
    return null;
  }

  /// ✅ حذف ملفات أو مجلدات عبر ID
  Future<bool> deleteContents(String contentsId) async {
    final url = Uri.parse('https://api.gofile.io/contents');
    final headers = {
      'Authorization': 'Bearer $_authToken',
      'Content-Type': 'application/json',
    };
    final body = '{"contentsId": "$contentsId"}';

    try {
      final response = await http.delete(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('🗑 Deleted successfully');
        return true;
      } else {
        print('❌ Delete failed: ${response.statusCode}');
        print(response.body);
        return false;
      }
    } catch (error) {
      print('❌ Exception deleting content: $error');
      return false;
    }
  }

  /// ✅ إظهار رسالة للمستخدم
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}