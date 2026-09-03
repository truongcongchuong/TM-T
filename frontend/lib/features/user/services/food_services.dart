import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/config/config.dart';
import 'package:frontend/core/models/food.dart';
import 'package:frontend/core/models/category_food.dart';
import 'package:frontend/core/models/food_response.dart';
import 'geolocator.dart';

class FoodService {

  Future<List<FoodResponse>> getAllFoods() async {
    final url = Uri.parse('$baseUrl/user/foods');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] != true) {
        return [];
      }
      return data['data']
          .map<FoodResponse>((foodData) => FoodResponse.fromMap(foodData))
          .toList();  
    } else {
      throw Exception('Failed to load foods');
    }
  }

  // filder food by id
  Future<FoodResponse> getFoodById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/user/foods/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return FoodResponse.fromMap(data['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Food not found');
    }
    else {
      throw Exception('Failed to load food');
    }
  }

  Future<List<CategoryFood>> getAllCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/user/foods/categories'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] != true) {
        return [];
      }
      return data['data']
          .map<CategoryFood>((categoryData) => CategoryFood.fromJson(categoryData))
          .toList();  
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<FoodResponse>> getFoodsByCategory(int categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/foods/category/$categoryId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      print(data);
      if (data['success'] != true) {
        return [];
      }
      return data['data']
          .map<FoodResponse>((foodData) => FoodResponse.fromMap(foodData))
          .toList();  
    } else {
      throw Exception('Failed to load foods by category');
    }
  }

  Future<List<FoodResponse>> recommendFood(int foodId, {int limit = 6}) async {
    final response = await http.get(Uri.parse('$baseUrl/public/recommendations/$foodId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] != true) {
        return [];
      }
      return data['data']
          .map<FoodResponse>((foodData) => FoodResponse.fromMap(foodData))
          .toList();  
    } else {
      throw Exception('Failed to load recommended foods');
    }
  }

  Future<List<FoodResponse>> searchFood(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/public/foods/search?query=$query'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      print(data);
      if (data['success'] != true) {
        return [];
      }
      final List list = data['data'];

      return list
          .map<FoodResponse>((foodData) => FoodResponse.fromMap(foodData))
          .toList();
    } else {
      throw Exception('Failed to search foods');
    }
  }
}

