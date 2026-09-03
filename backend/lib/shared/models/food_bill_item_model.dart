import 'package:backend/shared/models/food_model.dart';
import 'package:postgres/postgres.dart';

class FoodBillItemModel {
  final FoodModel food;
  final int quantity;

  FoodBillItemModel({
    required this.food,
    required this.quantity,
  });

  // ================= FROM MAP =================
  factory FoodBillItemModel.fromMap(Map<String, dynamic> map) {
    return FoodBillItemModel(
      food: FoodModel.fromMap(map['food']),
      quantity: map['quantity'] ?? 0,
    );
  }

  // ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'food': food.toMap(),
      'quantity': quantity,
    };
  }

  // ================= COPY WITH =================
  FoodBillItemModel copyWith({
    FoodModel? food,
    int? quantity,
  }) {
    return FoodBillItemModel(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }

  factory FoodBillItemModel.fromRow(ResultRow row) {
    final map = row.toColumnMap();
    return FoodBillItemModel(
      food: FoodModel.fromRow(row),
      quantity: map['quantity'] ?? 0,
    );
  }
}