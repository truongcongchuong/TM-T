import 'dart:convert';
import 'package:frontend/core/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/nontification.dart';

class NotificationService {
  Future<List<NotificationModel>> loadNotification(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/notification'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      final List<dynamic> data = json['data'];

      return data
          .map((item) => NotificationModel.fromMap(item))
          .toList();
    }

    return [];
  }
}