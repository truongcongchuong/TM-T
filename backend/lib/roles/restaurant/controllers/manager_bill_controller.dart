import 'package:shelf/shelf.dart';
import '../../../core/utils/response.dart';
import 'package:backend/shared/enum/user_role_enum.dart';
import '../services/manager_bill_service.dart';
import 'dart:convert';
class ManagerBillController {

  final ManagerBillService managerBillService = ManagerBillService();

  Future<Response> getBill(Request req) async {
    final restaurantId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }
    final bills = await managerBillService.getBill(restaurantId);

    if (bills == null) {
      return ResponseUtil.success([], message: 'No bills found for this restaurant');
    }
    return ResponseUtil.success(bills.map((bill) => bill.toMap()).toList());
  }

  Future<Response> getFoodItems(Request req, String billId) async {
    final ownerId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (ownerId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final items = await managerBillService.loadFoodItemsByBillId(int.parse(billId));

    return ResponseUtil.success(
      items.map((e) => e.toMap()).toList(),
    );
  }

  Future<Response> updateBill(Request req, String billId) async {
  final ownerId = req.context['userId'] as int?;
  final role = req.context['role'] as String?;

  if (ownerId == null || role != UserRoleEnum.restaurantOwner.value) {
    return ResponseUtil.unauthorized();
  }

  final body = jsonDecode(await req.readAsString());

  try {
    final updated = await managerBillService.updateBill(
      int.parse(billId),
      body,
      ownerId,
    );

    return ResponseUtil.success(
      updated,
      message: 'Update successful',
    );
  } catch (e) {
    return ResponseUtil.badRequest('Error: $e');
  }
}
}
