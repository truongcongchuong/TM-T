import 'package:backend/core/config/database.dart';
import 'package:backend/shared/models/bill_model.dart';
import 'package:backend/shared/models/payment_model.dart';
import 'package:postgres/postgres.dart';
import 'package:backend/shared/services/payment_service.dart';

class BillService {
  final PaymentService _paymentService = PaymentService();


  Future<int?> createBill(BillModel bill, PaymentModel payment) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      // BẮT ĐẦU TRANSACTION
      await conn.execute("BEGIN");

      // Insert bill
      final insertBill = await conn.execute(
        Sql.named(
          'INSERT INTO bills (user_id, order_time, status_id, address, phone_number) '
          'VALUES (@u_id, @order_time, @status_id, @address, @phone_number) RETURNING id',
        ),
        parameters: {
          'u_id': bill.userId,
          'order_time': bill.orderTime,
          'status_id': bill.statusId,
          'address': bill.address,
          'phone_number': bill.phoneNumber,
        },
      );

      final billId = insertBill.first[0] as int;

      // Insert detail
      for (final item in bill.items) {
        await conn.execute(
          Sql.named(
            'INSERT INTO detail_bill (bill_id, food_id, quantity) '
            'VALUES (@b_id, @f_id, @qty)',
          ),
          parameters: {
            'b_id': billId,
            'f_id': item.foodId,
            'qty': item.quantity,
          },
        );
      }

      // Insert payment
      await _paymentService.payment(
        payment.copyWith(billId: billId)
      );

      // COMMIT nếu mọi thứ OK
      await conn.execute("COMMIT");

      return billId;

    } catch (e) {
      print('Error occurred, rolling back transaction: $e');
      // ROLLBACK nếu xảy ra lỗi
      try {
        await conn.execute("ROLLBACK");
      } catch (_) {
        return -1;
      }

      print('Error creating bill: $e');
      return -1;
    } finally {
    }
  }

  Future<List<BillModel>> getBill() async {
    final Connection conn = await DatabaseConfig.connection();

    final results = await conn.execute(
      Sql.named(
        '''SELECT
          b.id,
          b.user_id,
          b.order_time,
          b.status,
          b.address,
          d.food_id,
          d.quantity,
          b.phone_number
        FROM bill b
        JOIN bill_detail d ON d.bill_id = b.id;
        ''',
      ),
    );

    // Group theo bill_id
    final Map<int, List<ResultRow>> grouped = {};

    for (final row in results) {
      final map = row.toColumnMap();
      final billId = map['id'] as int;

      grouped.putIfAbsent(billId, () => []);
      grouped[billId]!.add(row);
    }

    final re = grouped.values
        .map((rows) => BillModel.fromJoinedRows(rows))
        .toList();
    return re;
  }

  Future<bool> updateBillStatus(int billId, String status) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      await conn.execute(
        Sql.named('UPDATE bills SET status = @status WHERE id = @id'),
        parameters: {
          'status': status,
          'id': billId,
        },
      );
      return true;
    } catch (e) {
      print('Error updating bill status: $e');
      return false;
    } finally {
    }
  }

  Future<bool> deleteBill(int billId) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      await conn.execute(
        Sql.named('DELETE FROM bills WHERE id = @id'),
        parameters: {
          'id': billId,
        },
      );
      return true;
    } catch (e) {
      print('Error deleting bill: $e');
      return false;
    } finally {
    }
  }

  Future<bool> deleteDish(int billId, int foodId) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      await conn.execute(
        Sql.named('DELETE FROM detail_bill WHERE bill_id = @b_id AND food_id = @f_id'),
        parameters: {
          'b_id': billId,
          'f_id': foodId,
        },
      );
      return true;
    } catch (e) {
      print('Error deleting dish from bill: $e');
      return false;
    } finally {
    }
  }

  // lấy danh sách bill theo user_id
  Future<List<BillModel>> getBillsByUserId(int userId) async {
    final Connection conn = await DatabaseConfig.connection();

    final results = await conn.execute(
      Sql.named(
        '''SELECT
          b.id,
          b.user_id,
          b.order_time,
          b.status_id,
          b.address,
          d.food_id,
          d.quantity,
          b.phone_number
        FROM bills b
        JOIN detail_bill d ON d.bill_id = b.id
        WHERE b.user_id = @u_id;
        ''',
      ),
      parameters: {
        'u_id': userId,
      },
    );

    // Group theo bill_id
    final Map<int, List<ResultRow>> grouped = {};

    for (final row in results) {
      final map = row.toColumnMap();
      final billId = map['id'] as int;

      grouped.putIfAbsent(billId, () => []);
      grouped[billId]!.add(row);
    }

    final re = grouped.values
        .map((rows) => BillModel.fromJoinedRows(rows))
        .toList();
    return re;
  }

  // lấy danh sách bill theo id bill
  Future<BillModel?> getBillById(int billId) async {
    final Connection conn = await DatabaseConfig.connection();

    final results = await conn.execute(
      Sql.named(
        '''SELECT
          b.id,
          b.user_id,
          b.order_time,
          b.status,
          b.address,
          d.food_id,
          d.quantity,
          b.phone_number
        FROM bills b
        JOIN detail_bill d ON d.bill_id = b.id
        WHERE b.id = @b_id;
        ''',
      ),
      parameters: {
        'b_id': billId,
      },
    );

    if (results.isEmpty) {
      return null;
    }

    return BillModel.fromJoinedRows(results);
  }

  // lấy id trạng thái default
  static Future<int> getDefaultStatusId() async {
    final Connection conn = await DatabaseConfig.connection();

    final results = await conn.execute(
      Sql.named(
        '''SELECT
            s.id
          FROM status s
          INNER JOIN status_domain sd ON s.domain_id = sd.id
          WHERE s.name = 'chờ xử lý' AND sd.code = 'order';
        ''',
      ),
    );

    if (results.isNotEmpty) {
      return results.first[0] as int;
    }

    throw Exception("Default status 'chờ xử lý' not found");
  }

  // lấy id của nhà hàng của món ăn
  Future<int?> getRestaurantIdByFoodId(int foodId) async {
    final Connection conn = await DatabaseConfig.connection();

    final results = await conn.execute(
      Sql.named(
        '''SELECT r.id
          FROM restaurants r
          JOIN foods f ON f.restaurant_id = r.id
          WHERE f.id = @f_id;
        ''',
      ),
      parameters: {
        'f_id': foodId,
      },
    );

    if (results.isEmpty) return null;
    return results.first[0] as int;
  }
}
