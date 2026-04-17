import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../shared/services/food_service.dart';
import '../../../shared/models/food_model.dart';
import '../../../core/utils/response.dart';

class AdminFoodController {
  final FoodService _foodService = FoodService();

  Future<Response> createFood(Request req) async {
    final data = jsonDecode(await req.readAsString());
    final food = FoodModel.fromMap(data);

    final id = await _foodService.addFood(food);
    return ResponseUtil.success({'foodId': id});
  }
}