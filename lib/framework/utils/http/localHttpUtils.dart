import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../utils/http/HttpRequestException.dart';
import '../../../utils/http/HttpUtils.dart';


class LocalHttpUtils implements HttpUtils {
  static bool isLocalUrl(String url) {
    return url.startsWith('local://');
  }

   Future<String> getData(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    String? token,
    bool isConsole = false,
  }) async {
    if (isLocalUrl(url)) {
      return getlocalGetData(url);
    }
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final Map<String, String> finalHeaders = {...defaultHeaders, ...?headers};

    final Uri uri =
        queryParams != null
            ? Uri.parse(url).replace(queryParameters: queryParams)
            : Uri.parse(url);

    final response = await http.get(uri, headers: finalHeaders);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpRequestException(
        response.statusCode,
        'Request failed with status: ${response.statusCode}',
        response.body,
      );
    }

    return response.body;
  }

  static Future<String> getlocalGetData(String url) async {
    final path = url.substring(9);
    var path2 = path.replaceAll('/', '_');
    try {
      final directory = Directory.current.path;
      final filePath = '$directory/assets/fake/$path2.json';
      final file = File(filePath);
      if (!await file.exists()) {
        throw HttpRequestException(404, 'File not found: $filePath', null);
      }
      return await file.readAsString();
    } catch (e) {
      throw HttpRequestException(404, 'Error loading local data: $e', null);
    }
  }

 @override
  Future postData(String url, {Map<String, String>? headers, String? token, Map<String, dynamic>? body}) async {
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final Map<String, String> finalHeaders = {...defaultHeaders, ...?headers};

    final Uri uri = Uri.parse(url);

    final response = await http.post(uri, headers: finalHeaders, body: jsonEncode(body));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpRequestException(
        response.statusCode,
        'Request failed with status: ${response.statusCode}',
        response.body,
      );
    }

    return response.body;
  }

  @override
  Future putData(String url, {Map<String, String>? headers, String? token, Map<String, dynamic>? body}) async {
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final Map<String, String> finalHeaders = {...defaultHeaders, ...?headers};
    
    final Uri uri = Uri.parse(url);

    final response = await http.put(uri, headers: finalHeaders, body: jsonEncode(body));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpRequestException(
        response.statusCode,
        'Request failed with status: ${response.statusCode}',
        response.body,
      );
    }

    return response.body;
  }
  
}
