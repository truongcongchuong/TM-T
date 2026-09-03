import 'package:frontend/core/models/food.dart';

class FoodBillItemModel {
  final Food food;
  final int quantity;

  FoodBillItemModel({
    required this.food,
    required this.quantity,
  });

  // ================= FROM MAP =================
  factory FoodBillItemModel.fromMap(Map<String, dynamic> map) {
    return FoodBillItemModel(
      food: Food.fromJson(map['food']),
      quantity: map['quantity'] ?? 0,
    );
  }

  // ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'food': food.toJson(),
      'quantity': quantity,
    };
  }

  // ================= COPY WITH =================
  FoodBillItemModel copyWith({
    Food? food,
    int? quantity,
  }) {
    return FoodBillItemModel(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }
}