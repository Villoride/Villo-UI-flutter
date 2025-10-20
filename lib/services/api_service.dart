import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_base.dart';

class ApiService {
  static final String _base = ApiBase.baseUrl; // change if needed

  static Future<http.Response> postJson(String path, Map<String, dynamic> data) {
    final url = Uri.parse('$_base$path');
    return http
        .post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data))
        .timeout(const Duration(seconds: 15));
  }

  static Future<http.Response> get(String path) {
    final url = Uri.parse('$_base$path');
    return http.get(url).timeout(const Duration(seconds: 15));
  }
}
