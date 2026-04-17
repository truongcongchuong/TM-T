import 'package:shelf/shelf.dart';
import '../../../shared/services/cart_service.dart';
import '../../../core/utils/response.dart';
import '../../../shared/models/cart_model.dart';
import 'dart:convert';
import 'package:backend/shared/enum/user_role_enum.dart';

class UserCartController {

  final CartService cartService = CartService();

  Future<Response> getCart(Request req) async {
    final userId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (userId == null || role != UserRoleEnum.user.value) {
      return ResponseUtil.unauthorized();
    }

    final cartItems = await cartService.getCartByUser(userId);
    
    return ResponseUtil.success(cartItems);
  }

  Future<Response> addToCart(Request req) async {
    final userId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (userId == null || role != UserRoleEnum.user.value) {
      return ResponseUtil.unauthorized();
    }

    final json = jsonDecode(await req.readAsString()) as Map<String, dynamic>;

    json['user_id'] = userId;

    final cartItem = CartModel.fromMap(json);

    if (json.isEmpty) {
      return ResponseUtil.badRequest('Request body is empty');
    }

    try {
      final cartItems = await cartService.addItemToCart(cartItem);

      if (!cartItems) {
        return ResponseUtil.badRequest('Failed to add item to cart');
      }

      return ResponseUtil.success(cartItems);
    } catch (e) {
      return ResponseUtil.badRequest('Invalid request body: $e');
    }
  }
// ========================= xóa dỏ hàng =======================
  Future<Response> removeItemFromCart(Request req, String foodId) async {
    final userId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;
    final fId =  int.tryParse(foodId);

    if (fId == null) {
      return ResponseUtil.notFound("not found food id");
    }

    if (userId == null || role != UserRoleEnum.user.value) {
      return ResponseUtil.forbidden();
    }

    try {
      final result = await cartService.removeItemFromCart(userId, fId);

      return ResponseUtil.success(result);
    } catch (e) {
      return ResponseUtil.badRequest('Invalid request body: $e');
    }
  }




  // Future<Response> updateCart(Request req) async {
  //   final userId = req.context['userId'] as int?;

  //   if (userId == null) {
  //     return ResponseUtil.unauthorized();
  //   }

  //   final body = await req.readAsString();
  //   if (body.isEmpty) {
  //     return ResponseUtil.badRequest('Request body is empty');
  //   }

  //   try {
  //     final cartItems = await cartService.updateCart(userId, body);
  //     return ResponseUtil.success(cartItems);
  //   } catch (e) {
  //     return ResponseUtil.badRequest('Invalid request body: $e');
  //   }
  // }
}
