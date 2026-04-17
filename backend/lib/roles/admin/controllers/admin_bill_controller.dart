import 'package:shelf/shelf.dart';
import '../../../shared/services/bill_service.dart';
import '../../../core/utils/response.dart';

class AdminBillController {
  final BillService _billService = BillService();

  Future<Response> getBillById(Request req, String id) async {
    final billId = int.tryParse(id);
    if (billId == null) {
      return ResponseUtil.badRequest('Invalid bill ID');
    }

    final bill = await _billService.getBillById(billId);
    if (bill == null) {
      return ResponseUtil.notFound('Bill not found');
    }

    return ResponseUtil.success(bill.toMap());
  }

  Future<Response> deleteBill(Request req, String id) async {
    final billId = int.tryParse(id);
    if (billId == null) {
      return ResponseUtil.badRequest('Invalid bill ID');
    }

    final success = await _billService.deleteBill(billId);
    return success
        ? ResponseUtil.success(null, message: 'Bill deleted')
        : ResponseUtil.serverError('Delete failed');
  }
}
