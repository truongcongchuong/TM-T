import 'package:shelf/shelf.dart';
import '../../../core/utils/response.dart';
import 'dart:convert';
import '../../../shared/services/bill_service.dart';
import '../../../shared/models/bill_model.dart';
import '../../../shared/services/order_service.dart';
import 'package:backend/shared/enum/user_role_enum.dart';
import 'package:backend/shared/models/payment_model.dart';

class UserOrderController {
  Future<Response> order(Request req) async {
    try {
      OrderService orderService = OrderService();
        
      if (req.context['userId'] == null || req.context['role'] != UserRoleEnum.user.value) {
        return ResponseUtil.unauthorized();
      }
      final body = await req.readAsString();
      if (body.isEmpty) {
        return ResponseUtil.badRequest('Request body is empty');
      }
      final data = jsonDecode(body);
      print("Received order data: $data"); // Debug: In dữ liệu nhận được
      if (data["bill"]['status_id'] == null) {
        data["bill"]['status_id'] = await BillService.getDefaultStatusId();
      }

      final bill = BillModel.fromMap(data["bill"]);
      final payment = PaymentModel.fromMap(data["payment"]);

      final result = await orderService.createOrder(bill, payment);

      if (!result) {
        return ResponseUtil.badRequest('Failed to create order');
      }

      return ResponseUtil.success("Order placed successfully");
  
    } catch (e) {
      return ResponseUtil.badRequest('Invalid request body: $e');
    }
  }
}
