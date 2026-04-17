import 'package:frontend/core/enum/status.dart';

class BillManagerModel {
  final int id;
  final String customer;
  final OrderStatusEnum statusBill;
  final String paymentMethod;
  final PaymentStatusEnum statusPayment;
  final DateTime orderTime;
  final String address;

  BillManagerModel({
    required this.id,
    required this.customer,
    required this.statusBill,
    required this.paymentMethod,
    required this.statusPayment,
    required this.orderTime,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer': customer,
      'status_bill': statusBill.value,
      'payment_method': paymentMethod,
      'status_payment': statusPayment.value,
      'order_time': orderTime.toIso8601String(),
      'address': address,
    };
  }

  factory BillManagerModel.fromMap(Map<String, dynamic> map) {
    return BillManagerModel(
      id: map['id'],
      customer: map['customer'],
      statusBill: OrderStatusEnum.fromString(map['status_bill']),
      paymentMethod: map['payment_method'],
      statusPayment: PaymentStatusEnum.fromString(map['status_payment']),
      orderTime: DateTime.parse(map['order_time']),
      address: map['address'],
    );
  }
}