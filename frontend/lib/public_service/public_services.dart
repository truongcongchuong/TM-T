import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/config/config.dart';
import 'package:frontend/core/models/category_food.dart';

class PublicServices {
  Future<String?> getNameCategoryById(int id) async {
    final url = Uri.parse('$baseUrl/public/category/$id');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final String category = jsonData['data']['name'];
      if (category.isEmpty) return null;
      return category;
    } else {
      throw Exception('Failed to load order status');
    }
  }

  Future<List<CategoryFood>> getAllCategories() async {
    final url = Uri.parse('$baseUrl/public/categories');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List<dynamic> categoriesJson = jsonData['data'];
      return categoriesJson.map((json) => CategoryFood.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}