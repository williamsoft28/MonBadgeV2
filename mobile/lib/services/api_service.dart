import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET
  static Future<dynamic> get(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  // POST
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  // DELETE
  static Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }
}