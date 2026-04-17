import 'package:postgres/postgres.dart';

class CartModel {
  final int userId;
  final int foodId;
  final int quantity;

  CartModel({
    required this.userId,
    required this.foodId,
    required this.quantity,
  });

  CartModel copyWith({
    int? userId,
    int? foodId,
    int? quantity,
  }) {
    return CartModel(
      userId: userId ?? this.userId,
      foodId: foodId ?? this.foodId,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartModel.fromRow(ResultRow row) {
    final data = row.toColumnMap();
    return CartModel(
      userId: data['user_id'] as int,
      foodId: data['food_id'] as int,
      quantity: data['quantity'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "food_id": foodId,
      "quantity": quantity,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      userId: map['user_id'] as int,
      foodId: map['food_id'] as int,
      quantity: map['quantity'] as int,
    );
  }
}