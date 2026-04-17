import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';

class BillFoodItem {
  final int foodId;
  final int quantity;

  BillFoodItem({
    required this.foodId,
    required this.quantity,
  });

  factory BillFoodItem.fromMap(Map<String, dynamic> map) {
    return BillFoodItem(
      foodId: map['food_id'],
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
    'food_id': foodId,
    'quantity': quantity,
  };
}

class BillModel {
  final int? id;
  final int userId;
  final String phoneNumber;
  final DateTime orderTime;
  final int statusId;
  final String? address;
  final List<BillFoodItem> items;

  BillModel({
    this.id,
    required this.userId,
    required this.orderTime,
    required this.phoneNumber,
    required this.statusId,
    required this.address,
    required this.items,
  });

  /// Factory async để tự động lấy default_address nếu address rỗng
  static Future<BillModel> create({
    int? id,
    required int userId,
    required String phoneNumber,
    DateTime? orderTime,
    required int statusId,
    String? address,
    required List<BillFoodItem> item,
  }) async {
    // Nếu address bị null hoặc rỗng -> lấy default address từ DB
    final finalAddress = (address == null || address.isEmpty)
        ? await getDefaultAddress(userId)
        : address;

    return BillModel(
      id: id,
      userId: userId,
      phoneNumber: phoneNumber,
      orderTime: orderTime ?? DateTime.now(),
      statusId: statusId,
      address: finalAddress,
      items: item,
    );
  }

  /// Truy vấn PostgreSQL để lấy default_address
  static Future<String> getDefaultAddress(int userId) async {
    final Connection conn = await DatabaseConfig.connection();
    final result = await conn.execute(
      Sql('SELECT default_address FROM users WHERE id = @id'),
      parameters: {"id": userId},
    );
    await conn.close();

    if (result.isEmpty) return "";
    return result.first[0] as String;
  }

  /// Parse từ PostgreSQL Row
  factory BillModel.fromJoinedRows(List<ResultRow> rows) {
    if (rows.isEmpty) {
      throw StateError('Bill not found');
    }

    final first = rows.first.toColumnMap();

    final items = rows.map((row) {
      final data = row.toColumnMap();
      return BillFoodItem(
        foodId: data['food_id'],
        quantity: data['quantity'],
      );
    }).toList();

    return BillModel(
      id: first['id'],
      userId: first['user_id'],
      phoneNumber: first['phone_number'],
      orderTime: first['order_time'],
      statusId: first['status_id'],
      address: first['address'],
      items: items,
    );
  }

  /// Trả JSON về API
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "user_id": userId,
      "phone_number": phoneNumber,
      "order_time": orderTime.toIso8601String(),
      "status_id": statusId,
      "address": address,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'],
      userId: map['user_id'],
      phoneNumber: map['phone_number'],
      orderTime: map['order_time'] != null
                ? DateTime.parse(map['order_time'])
                : DateTime.now(),
      statusId: map['status_id'],
      address: map['address'],
      items: (map['items'] as List)
          .map((e) => BillFoodItem.fromMap(e))
          .toList(),
    );
  }
}
