import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/config/config.dart';
import 'package:frontend/core/models/user.dart';

class ProfileService {
  Future<(bool success, String message)> updateProfile(
    User user,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/profile/update');
    try {
      final response = await http.put(
        url,
        headers: {
          ...headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': user.username,
          'email': user.email,
          'phonenumber': user.phoneNumber,
          'default_address': user.defaultAddress,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return (true, jsonData['message'] as String);
      } else {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return (false, jsonData['error'] as String);
      }
    } catch (e) {
      return (false, 'Lỗi kết nối: ${e.toString()}');
    }
  }
}
