import 'package:shelf/shelf.dart';
import '../../../shared/services/food_service.dart';
import '../../../core/utils/response.dart';

class UserFoodController {
  final FoodService _foodService = FoodService();

  Future<Response> getFoods(Request req) async {
    final foods = await _foodService.getAllFoods();
    return ResponseUtil.success(
      foods.map((f) => f.toMap()).toList(),
    );
  }

  Future<Response> getCategorysFood(Request req) async {
    final categories = await _foodService.getAllCategories();
    return ResponseUtil.success(
      categories.map((c) => c?.toMap()).toList(),
    );
  }

  Future<Response> getFoodsByCategory(Request req, String categoryId) async {
    final int catId = int.tryParse(categoryId) ?? 0;
    final foods = await _foodService.getFoodsByCategory(catId);
    return ResponseUtil.success(
      foods.map((f) => f.toMap()).toList(),
    );
  }

  Future<Response> getFoodById(Request req, String foodId) async {
    final int fId = int.tryParse(foodId) ?? 0;
    final food = await _foodService.getFoodById(fId);
    return ResponseUtil.success(food?.toMap());
  }
}
