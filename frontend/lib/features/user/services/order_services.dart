import 'dart:convert';
import 'package:frontend/core/models/bill.dart';
import 'package:frontend/core/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/enum/method_payment.dart';
import 'package:frontend/core/models/payment_model.dart';

class OrderServices {
  Future<bool> order(String token,Bill bill,PaymentModel payment ) async {
    final url = Uri.parse('$baseUrl/user/orders');
    try {
      final response = await http.post(
        url,
        headers: {
          ...headers,
          'Authorization': 'Bearer $token',
          },
        body: jsonEncode({
          "bill": bill.toJson(),
          "payment": payment.toMap()
        }),
        
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<int> fetchPaymentMethods(MethodPayment method) async {
    final res = await http.get(
      Uri.parse('$baseUrl/public/paymentMethod/${method.value}'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"] as int;
    } else {
      throw Exception('Failed to load payment methods');
    }
  }
}