import 'package:backend/shared/enum/payment_method_enum.dart';
import 'package:backend/core/config/database.dart';
import 'package:postgres/postgres.dart';
import 'package:backend/shared/models/payment_model.dart';

class PaymentService {

  Future<int> getPaymentMethodId(MethodPayment paymentMethod) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named('''
        SELECT id 
        FROM method_payment 
        WHERE name = @name
        LIMIT 1
      '''),
      parameters: {
        'name': paymentMethod.value,
      },
    );

    if (result.isEmpty) {
      throw Exception('Payment method not found');
    }

    return result.first[0] as int;
  }

  Future<int> payment(PaymentModel payment) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named('''
        INSERT INTO payments (bill_id, method_id, status_id, paid_at)
        VALUES (@billId, @methodId, @statusId, NOW())
        RETURNING id
      '''),
      parameters: {
        'billId': payment.billId,
        'methodId': payment.methodId,
        'statusId': payment.statusId,
      },
    );

    if (result.isEmpty) {
      throw Exception('Insert payment failed');
    }

    return result.first[0] as int;
  }
}