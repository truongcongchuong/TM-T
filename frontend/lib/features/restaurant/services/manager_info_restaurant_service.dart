import 'package:frontend/core/config/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/restaurant.dart';

class ManagerInfoRestaurantServices {

  Future<RestaurantModel> getInfoRestaurant(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurant/manager/info'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return RestaurantModel.fromMap(data['data']);
    } else {
      throw Exception('Failed to load manager bills');
    }
  }

  Future<bool> updateInfoRestaurant(RestaurantModel restaurant, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/restaurant/manager/info'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(restaurant.toMap())
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}