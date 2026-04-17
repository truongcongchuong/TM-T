import 'package:shelf/shelf.dart';
import '../../../shared/services/bill_service.dart';
import '../../../core/utils/response.dart';
import 'package:backend/shared/enum/user_role_enum.dart';

class UserBillController {
  final BillService billService = BillService();

  Future<Response> getBills(Request req) async {
    final userId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (userId == null || role != UserRoleEnum.user.value) {
      return ResponseUtil.unauthorized();
    }

    final bills = await billService.getBillsByUserId(userId);
    return ResponseUtil.success(bills.map((b) => b.toMap()).toList());
  }
}
