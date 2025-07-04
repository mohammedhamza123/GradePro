import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class InternetService {
  static final InternetService _internetService = InternetService._internal();
  //static const String _urlString = "http://10.0.2.2:8000";
    static const String _urlString = "https://easy0123.pythonanywhere.com";
  //static const String _urlString = "http://127.0.0.1:8000";
  //static const String _urlString = "http://192.168.2.129:8000";
  String _token = "";

  // const username = "tahasuperuser";
  // const password = "";
 
  factory InternetService() {
    return _internetService;
  }

  InternetService._internal();

  Future<http.Response> get(String endpoint, Map<String, String>? queryParams) {
    String urlString = "";
    if (queryParams != null) {
      urlString = _addQueryParams(queryParams, _urlString + endpoint);
    } else {
      urlString = _urlString + endpoint;
    }
    final url = Uri.parse(urlString);
    
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    
    // Only add Authorization header if token is not empty
    if (_token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) {
    final url = Uri.parse(_urlString + endpoint);
    
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    
    // Only add Authorization header if token is not empty
    if (_token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
      encoding: Encoding.getByName("utf-8"),
    );
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> data) {
    final url = Uri.parse(_urlString + endpoint);
    
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    
    // Only add Authorization header if token is not empty
    if (_token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return http.patch(
      url,
      headers: headers,
      body: jsonEncode(data),
      encoding: Encoding.getByName("utf-8"),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) {
    final url = Uri.parse(_urlString + endpoint);
    
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    
    // Only add Authorization header if token is not empty
    if (_token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
      encoding: Encoding.getByName("utf-8"),
    );
  }

  Future<http.Response> delete(String endpoint) {
    final url = Uri.parse(_urlString + endpoint);
    
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    
    // Only add Authorization header if token is not empty
    if (_token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return http.delete(
      url,
      headers: headers,
      encoding: Encoding.getByName("utf-8"),
    );
  }

  Future<http.Response> postFormDataImage(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse(endpoint);
    var request = http.MultipartRequest('POST', url);
    request.fields['key'] = data["key"];
    request.fields['image'] = data["image"];
    // request.files.add(await http.MultipartFile.fromPath('file', 'path_to_file'));
    request.headers['Content-Type'] = 'multipart/form-data';
    var response = await request.send();
    return await http.Response.fromStream(response);
  }

  bool isAuthorized() {
    if (_token.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void setToken(String token) {
    _token = token;
  }

  void removeToken() {
    _token = "";
  }

  String? getToken() {
    return _token.isNotEmpty ? _token : null;
  }

  String _addQueryParams(Map<String, dynamic> params, String url) {
    String result = "$url?";
    for (var param in params.keys) {
      result += "$param=${params[param]}";
    }
    return result;
  }
}
