import 'package:frontend/core/config/config.dart';
import 'package:frontend/core/models/food.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class ManagerFoodsServices {

  Future<List<Food>> getFoods(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurant/manager/foods'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body)['data'] as List)
          .map((e) => Food.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load manager foods');
    }
  }

  // upload ảnh và trả về url mới, sau đó gọi API editFood với url mới này

  Future<String> uploadImageFood(String token, PlatformFile file) async {
    final uri = Uri.parse('$baseUrl/restaurant/upload/imageFood');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        file.bytes!, // ✅ dùng bytes
        filename: file.name,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Failed to upload image');
    }

    return jsonDecode(body)['data']['fileName'] as String;
  }

  Future<Food?> editFood(String token, Food food, String? newImageUrl) async {
    final response = await http.put(
      Uri.parse('$baseUrl/restaurant/manager/foods'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'food': food.toJson(),
        'newImageUrl': newImageUrl,
      }),
    );
    print(food.toJson());
    print(newImageUrl);

    print("data json: ${jsonDecode(response.body)}");

    if (response.statusCode == 200) {
      return Food.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to edit food');
    }
  }

  Future<bool> deleteFood(String token, int foodId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/restaurant/manager/foods/$foodId'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Food?> addFood(String token, Food food) async {
    final response = await http.post(
      Uri.parse('$baseUrl/restaurant/manager/foods'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(food.toJson()),
    );

    if (response.statusCode != 200) {
      return null;
    }
    return Food.fromJson(jsonDecode(response.body)['data']);
  }
}