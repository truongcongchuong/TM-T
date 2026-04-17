import 'package:postgres/postgres.dart';

class ReviewModel {
  final int id;
  final int foodId;
  final int userId;
  final int rating;
  final String comment;
  final DateTime createAt;

  ReviewModel({
    required this.id,
    required this.foodId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      foodId: json['food_id'],
      userId: json['user_id'],
      rating: json['rating'],
      comment: json['comment'],
      createAt: json['create_at'] is DateTime
          ? json['create_at']
          : DateTime.parse(json['create_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_id': foodId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'create_at': createAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromRow(ResultRow row) {
    final data = row.toColumnMap();
    return ReviewModel.fromJson(data);
  }
}