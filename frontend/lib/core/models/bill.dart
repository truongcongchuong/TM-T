import 'dart:convert';

class BillItem {
  final int foodId;
  final int quantity;

  BillItem({
    required this.foodId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'food_id': foodId,
        'quantity': quantity,
      };

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        foodId: json['food_id'],
        quantity: json['quantity'],
      );
}

class Bill {
  final int? id;
  final int userId;
  final String address;
  final List<BillItem> items;
  final String phoneNumber;
  final String? note;
  final DateTime? orderTime;
  final int? statusId;

  Bill({
    this.id,
    required this.userId,
    required this.address,
    required this.items,
    required this.phoneNumber,
    this.note,
    this.orderTime,
    this.statusId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'phone_number': phoneNumber,
    'address': address,
    'note': note,
    'order_time': orderTime?.toIso8601String(),
    'status_id': statusId,
    'items': items.map((e) => e.toJson()).toList(),
    };

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    id: json["id"],
    userId: json["user_id"],
    phoneNumber: json['phone_number'],
    address: json['address'],
    note: json['note'],
    orderTime: json['order_time'] != null
        ? DateTime.parse(json['order_time'])
        : null,
    statusId: json['status_id'],
    items: (json['items'] as List)
        .map((e) => BillItem.fromJson(e))
        .toList(),
    );
  String toJsonString() => jsonEncode(toJson());

  Bill copyWith({
    String? phoneNumber,
    String? customerAddress,
    List<BillItem>? items,
  }) {
    return Bill(
      id: id,
      userId: userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: customerAddress ?? address,
      note: note ??note,
      orderTime: orderTime,
      items: items ?? this.items,
      statusId: statusId,
    );
  }
}
