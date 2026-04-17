import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/config/config.dart';
import 'package:frontend/core/models/cart.dart';

class CartService {
  
  Future<Cart> loadCart(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/carts'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] != true) {
        return Cart(
          userId: id,
          items: []
        );
      }
      return Cart.fromJson(data['data']);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  // thêm vào giỏ hàng
  Future<bool> addToCart(String token, ItemCart item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/carts'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'food_id': item.food.id,
        'quantity': item.quantity,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }

  // ===================== delete item cart ================

  Future<bool> removeItemCart(String token, int foodId) async {

    final response = await http.delete(
      Uri.parse('$baseUrl/user/carts/$foodId'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data["data"] as bool;
    } else {
      return false;
    }
  }
}