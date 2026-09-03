import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import '../models/bill_model.dart';
import 'package:backend/shared/models/food_bill_item_model.dart';


class ManagerBillService {

  Future<List<BillManagerModel>?> getBill(int ownerId) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        SELECT DISTINCT 
          b.id,
          u.username AS customer,
          status_bill.name AS status_bill,
          b.address,
          b.order_time,
          mp.name AS payment_method,
          status_payment.name AS status_payment
        FROM bills b
        JOIN detail_bill db ON b.id = db.bill_id
        JOIN foods f ON db.food_id = f.id
        JOIN status status_bill ON b.status_id = status_bill.id
        JOIN users u ON b.user_id = u.id
        JOIN payments p ON b.id = p.bill_id
        JOIN status status_payment ON p.status_id = status_payment.id
        JOIN method_payment mp ON p.method_id = mp.id
        JOIN restaurants r ON r.id = f.restaurant_id
        WHERE r.owner = @ownerId
        ORDER BY b.order_time DESC;
        '''
      ),
      parameters: {
        'ownerId': ownerId,
      },
    );

    if (result.isEmpty) return null;
    return result.map((row) => BillManagerModel.fromRow(row)).toList();
  }

  Future<List<FoodBillItemModel>> loadFoodItemsByBillId(int billId) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        SELECT 
          f.id,
          f.name,
          f.price,
          f.image_url,
          f.rating_avg,
          f.is_available,
          f.category_id,
          f.restaurant_id,
          f.preparation_time,
          f.description,
          db.quantity
        FROM detail_bill db
        JOIN foods f ON db.food_id = f.id
        WHERE db.bill_id = @billId;
        '''
      ),
      parameters: {
        'billId': billId,
      },
    );

    return result
        .map((row) => FoodBillItemModel.fromRow(row))
        .toList();
  }

  Future<bool> updateBill(
    int billId,
    Map<String, dynamic> data,
    int ownerId,
  ) async {
    final conn = await DatabaseConfig.connection();

    try {
      await conn.execute('BEGIN');

      // ===== 1. UPDATE PAYMENT =====
      await conn.execute(
        Sql.named('''
          UPDATE payments
          SET status_id = (
            SELECT id FROM status WHERE name = @status_payment
          )
          WHERE bill_id = @billId;
        '''),
        parameters: {
          'billId': billId,
          'status_payment': data['status_payment'],
        },
      );

      // ===== 2. UPDATE BILL =====
      await conn.execute(
        Sql.named('''
          UPDATE bills b
          SET 
            address = @address,
            status_id = (
              SELECT id FROM status WHERE name = @status_bill
            )
          FROM detail_bill db
          JOIN foods f ON db.food_id = f.id
          JOIN restaurants r ON r.id = f.restaurant_id
          WHERE b.id = @billId
            AND db.bill_id = b.id
            AND r.owner = @ownerId
        '''),
        parameters: {
          'billId': billId,
          'ownerId': ownerId,
          'address': data['address'],
          'status_bill': data['status_bill'],
        },
      );

      await conn.execute('COMMIT');


      return true;

    } catch (e) {
      await conn.execute('ROLLBACK');
      print('Update bill error: $e');
      return false;
    }
  }
}