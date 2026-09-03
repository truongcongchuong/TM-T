import "food_model.dart";
import "restaurant_model.dart";
import 'package:postgres/postgres.dart';

class FoodResponse {
  final FoodModel food;
  final RestaurantModel restaurant;

  FoodResponse({
    required this.food,
    required this.restaurant,
  });

  /// Parse từ PostgreSQL row
  factory FoodResponse.fromRow(ResultRow row) {
    final data = row.toColumnMap();
    return FoodResponse.fromMap(data);
  }
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }
  /// Parse từ Map
  factory FoodResponse.fromMap(Map<String, dynamic> map) {
    return FoodResponse(
      food: FoodModel(
        id: map['food_id'],
        name: map['food_name'] ?? '',
        price: _toDouble(map['price']), // ✅ FIX
        description: map['description'] ?? '',
        imageUrl: map['image_url'] ?? '',
        ratingAvg: map['food_rating_avg'] != null
            ? _toDouble(map['food_rating_avg']) // ✅ FIX
            : null,
        isAvailable: map['is_available'],
        categoryId: map['category_id'],
        restaurantId: map['restaurant_id'],
        preparationTime: map['preparation_time'] ?? 15,
      ),

      restaurant: RestaurantModel(
        id: map['restaurant_id'],
        name: map['restaurant_name'] ?? '',
        owner: map['owner'] ?? '',
        address: map['address'] ?? '',
        latitude: _toDouble(map['latitude']),   // ✅ FIX
        longitude: _toDouble(map['longitude']), // ✅ FIX
        isOpen: map['is_open'] ?? false,
        ratingAvg: map['restaurant_rating_avg'] != null
            ? _toDouble(map['restaurant_rating_avg']) // ✅ FIX
            : 0.0,
        createdAt: map['created_at'],
      ),
    );
  }

  /// Convert trả về frontend (nested)
  Map<String, dynamic> toMap() {
    return {
      "food": food.toMap(),
      "restaurant": restaurant.toMap(),
    };
  }

  /// 🔥 copyWith
  FoodResponse copyWith({
    FoodModel? food,
    RestaurantModel? restaurant,
  }) {
    return FoodResponse(
      food: food ?? this.food,
      restaurant: restaurant ?? this.restaurant,
    );
  }
}