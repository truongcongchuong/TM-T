import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import '../models/bill_model.dart';

class ManagerBillService {

  Future<List<Bill>?> getBill(int restaurantId) async {
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
        WHERE f.restaurant_id = @restaurantId
        ORDER BY b.order_time DESC;
        '''
      ),
      parameters: {
        'restaurantId': restaurantId,
      },
    );

    if (result.isEmpty) return null;
    return result.map((row) => Bill.fromRow(row)).toList();
  }
}