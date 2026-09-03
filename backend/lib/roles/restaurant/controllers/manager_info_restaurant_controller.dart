import 'package:backend/shared/models/restaurant_model.dart';
import 'package:shelf/shelf.dart';
import 'package:backend/shared/enum/user_role_enum.dart';
import '../../../core/utils/response.dart';
import 'package:backend/roles/restaurant/services/manager_restaurant_service.dart';
import 'dart:convert';

class ManagerInfoRestaurantController {
  final ManagerInfoRestaurantService managerInfoRestaurantService = ManagerInfoRestaurantService();

  Future<Response> getInfoRestaurant(Request req) async {
    final ownerId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    // ===== AUTH CHECK =====
    if (ownerId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    try {
      final info = await managerInfoRestaurantService.getInfoRestaurant(ownerId);

      // ===== NOT FOUND =====
      if (info == null) {
        return ResponseUtil.notFound(
          "Restaurant không tồn tại",
        );
      }

      // ===== SUCCESS =====
      return ResponseUtil.success(info.toMap());
    } catch (e) {
      // ===== SERVER ERROR =====
      print(e);
      return ResponseUtil.serverError(
        "Lỗi server: $e",
      );
    }
  }

  Future<Response> updateInfoRestaurant(Request req) async {
    final ownerId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    // ===== AUTH CHECK =====
    if (ownerId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    try {
      final json = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      RestaurantModel restaurant = RestaurantModel.fromMap(json);
      final result = await managerInfoRestaurantService.updateInfo(restaurant);

      // ===== SUCCESS =====
      return ResponseUtil.success(result);
    } catch (e) {
      // ===== SERVER ERROR =====
      print(e);
      return ResponseUtil.serverError(
        "Lỗi server: $e",
      );
    }
  }
}