import 'dart:convert';
import 'package:frontend/core/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/config/config.dart';
import 'package:frontend/core/models/api_response_model.dart';
import 'package:frontend/core/models/auth_response_model.dart';

class LoginServices {

  Future<ApiResponse<AuthResponse>> login(String account, String password) async {

    if (account.isEmpty || password.isEmpty) {
      throw Exception('Account and password must not be empty');
    }

    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({
        'account': account,
        'password': password,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to login: ${res.statusCode}');
    }

    
    final json = jsonDecode(res.body);
    final apiResponse = ApiResponse<AuthResponse>.fromJson(
      json,
      (data) => AuthResponse.fromJson(data),
    );
    return apiResponse;
  }


  Future<int> register(User user) async {
    print(user.toJson());
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      print("$baseUrl/auth/register");
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(user.toJson()),
      );
      print("dữ liệu trả về $jsonDecode(response.body)");
      if (response.statusCode == 200) {
        print("vào 200");
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData["data"]["id"] as int;
      } else {
        return -1;
      }
    } catch (e) {
      print(e);
      return -1;
    }
  }
}
