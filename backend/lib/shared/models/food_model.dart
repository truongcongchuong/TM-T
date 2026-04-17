import 'package:postgres/postgres.dart';

class FoodModel {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double? ratingAvg;
  final bool? isAvailable;
  final int? categoryId;
  final int restaurantId;

  FoodModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.ratingAvg,
    this.isAvailable,
    this.categoryId,
    required this.restaurantId,
  });

  // Dùng Row thay vì PostgreSQLResultRow
  factory FoodModel.fromRow(ResultRow row) {
    final data = row.toColumnMap(); // chuyển sang map theo tên cột
    return FoodModel.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "image_url": imageUrl,
      "rating_avg": ratingAvg,
      "is_available": isAvailable,
      "category_id": categoryId,
      "restaurant_id": restaurantId,
    };
  }
  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] is double
          ? map['price'] as double
          : double.parse(map['price'].toString()),
      imageUrl: map['image_url'] as String,
      ratingAvg: map['rating_avg'] != null ? double.parse(map['rating_avg'].toString()) : null,
      isAvailable: map['is_available'] as bool?,
      categoryId: map['category_id'] as int?,
      restaurantId: map['restaurant_id'] as int,
    );
  }
}