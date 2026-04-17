import 'package:shelf/shelf.dart';
import 'package:backend/shared/enum/user_role_enum.dart';
import '../../../core/utils/response.dart';
import '../services/manager_foods_service.dart';
import 'dart:convert';
import '../../../shared/models/food_model.dart';
import 'package:backend/shared/services/upload_file_service.dart';

class ManagerFoodController {
  final ManagerFoodsService managerFoodsService = ManagerFoodsService();
  final UploadFileService uploadFileService = UploadFileService();

  Future<Response> getFoodsForManager(Request req) async {
    final restaurantId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final foods = await managerFoodsService.getFoodsForManager(restaurantId.toString());
    
    return ResponseUtil.success(foods.map((food) => food.toMap()).toList());
  }

  Future<Response> editFood(Request req) async {
    final restaurantId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final json = jsonDecode(await req.readAsString()) as Map<String, dynamic>;

    if (json.isEmpty) {
      return ResponseUtil.badRequest('Request body is empty');
    }

    final newNameImg = json['newImageUrl'] as String?;
    final newInfFood = FoodModel.fromMap(json['food'] as Map<String, dynamic>);


    if (newInfFood.restaurantId != restaurantId) {
      return ResponseUtil.unauthorized();
    }

    try {
      final updatedFood = await managerFoodsService.editFood(newInfFood, newNameImg);

      if (updatedFood == null) {

        return ResponseUtil.badRequest('Failed to update food');
      }

      return ResponseUtil.success(updatedFood.toMap(), message: 'Food updated successfully');
    } catch (e) {
      return ResponseUtil.badRequest('Invalid request body: $e');
    }
  }

  Future<Response> deleteFood(Request req, String foodId) async {
    final restaurantId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    try {
      final isNumeric = int.tryParse(foodId) != null;
      if (!isNumeric) {
        return ResponseUtil.badRequest('Invalid food ID');
      }
      final isDeleted = await managerFoodsService.deleteFood(restaurantId, int.parse(foodId));

      if (!isDeleted) {
        return ResponseUtil.badRequest('Failed to delete food');
      }

      return ResponseUtil.success(isDeleted, message: 'Food deleted successfully');
    } catch (e) {
      return ResponseUtil.badRequest('Error deleting food: $e');
    }
  }

  Future<Response> addFood(Request req) async {
    final restaurantId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final json = jsonDecode(await req.readAsString()) as Map<String, dynamic>;

    if (json.isEmpty) {
      return ResponseUtil.badRequest('Request body is empty');
    }

    final newFood = FoodModel.fromMap(json);

    if (newFood.restaurantId != restaurantId) {
      return ResponseUtil.unauthorized();
    }

    try {
      final addedFood = await managerFoodsService.addFood(newFood);

      if (addedFood == null) {
        return ResponseUtil.badRequest('Failed to add food');
      }

      return ResponseUtil.success(addedFood.toMap(), message: 'Food added successfully');
    } catch (e) {
      return ResponseUtil.badRequest('Invalid request body: $e');
    }
  }
}