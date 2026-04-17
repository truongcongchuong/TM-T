import 'package:shelf/shelf.dart';
import '../../../core/utils/response.dart';
import 'package:backend/shared/enum/user_role_enum.dart';
import '../services/manager_bill_service.dart';

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
}
