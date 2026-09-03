import "food.dart";
import "restaurant.dart";

class FoodResponse {
  final Food food;
  final RestaurantModel restaurant;

  FoodResponse({
    required this.food,
    required this.restaurant,
  });

  /// Parse từ Map
  factory FoodResponse.fromMap(Map<String, dynamic> map) {
    return FoodResponse(
      food: Food.fromJson(map["food"]),
      restaurant: RestaurantModel.fromMap(map["restaurant"])
    );
  }

  /// Convert trả về frontend (nested)
  Map<String, dynamic> toMap() {
    return {
      "food": food.toJson(),
      "restaurant": restaurant.toMap(),
    };
  }

  /// 🔥 copyWith
  FoodResponse copyWith({
    Food? food,
    RestaurantModel? restaurant,
  }) {
    return FoodResponse(
      food: food ?? this.food,
      restaurant: restaurant ?? this.restaurant,
    );
  }
}