import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gradpro/models/file_direct_link.dart';
import 'package:gradpro/models/file_response.dart';
import 'package:flutter/material.dart';
import 'package:gradpro/services/models_services.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  static const String _authToken = "kwCRr4gOqLfKWBLBvg75A66raFXOb44j";
  static const String _folderToken = "bf822299-e50c-42b3-957c-8eb7d383b9c8";
  static const String _filesHost =
      "https://upload.gofile.io/uploadfile"; // Updated to GoFile global endpoint

  factory FileService() => _instance;
  FileService._internal();

  /// Uploads a file to GoFile. If [folderId] is provided, uploads to that folder.
  Future<FileResponse?> uploadFile(File file, {String? folderId}) async {
    final request = http.MultipartRequest('POST', Uri.parse(_filesHost))
      ..headers['Authorization'] = _authToken;

    if (folderId != null) {
      request.fields['folderId'] = folderId;
    } else {
      request.fields['folderId'] = _folderToken;
    }
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return fileResponseFromJson(responseBody);
    } else {
      getApiKey();
      print('Error uploading file: ${response.statusCode}');
      return null;
    }
  }

  /// Fetches direct download links for a file or folder by its [fileId].
  Future<FileDirectLink?> fetchDirectLink(String fileId) async {
    final url = Uri.parse('https://api.gofile.io/contents/$fileId/directlinks');
    final headers = {'Authorization': _authToken};

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        return fileDirectLinkFromJson(response.body);
      } else {
        print('Error fetching direct link: ${response.statusCode}');
        print(response.body);
        getApiKey();
      }
    } catch (error) {
      print('Error fetching direct link: $error');
    }
    return null;
  }

  /// Deletes files or folders by their IDs (comma-separated).
  Future<bool> deleteContents(String contentsId) async {
    final url = Uri.parse('https://api.gofile.io/contents');
    final headers = {
      'Authorization': _authToken,
      'Content-Type': 'application/json',
    };
    final body = '{"contentsId": "$contentsId"}';

    try {
      final response = await http.delete(url, headers: headers, body: body);
      return response.statusCode == 200;
    } catch (error) {
      getApiKey();
      print('Error deleting contents: $error');
      return false;
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
