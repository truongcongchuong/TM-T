import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import 'package:backend/shared/models/review_model.dart';

class ReviewsService {

  Future<List<ReviewModel>> getAllReviews(int foodId) async {
    final conn = await DatabaseConfig.connection();

    try {
      final result = await conn.execute(
        Sql.named("SELECT * FROM reviews WHERE food_id = @id ORDER BY create_at DESC"),
        parameters: {"id": foodId},
      );

      return result
          .map((row) => ReviewModel.fromRow(row))
          .toList();
    } catch (e) {
      print("Error getAllReviews: $e");
      return [];
    } 
  }

  Future<(ReviewModel?, double?)> createReview(ReviewModel review) async {
    final conn = await DatabaseConfig.connection();

    try {
      return await conn.runTx((tx) async {

        final result = await tx.execute(
          Sql.named('''
            INSERT INTO reviews (food_id, user_id, rating, comment, create_at)
            VALUES (@foodId, @userId, @rating, @comment, NOW())
            RETURNING id, food_id, user_id, rating, comment, create_at
          '''),
          parameters: {
            'foodId': review.foodId,
            'userId': review.userId,
            'rating': review.rating,
            'comment': review.comment,
          },
        );

        if (result.isEmpty) return (null, null);

        final insertedReview = ReviewModel.fromRow(result.first);

        final ratingResult = await tx.execute(
          Sql.named('''
            UPDATE foods
              SET rating_avg = (
                SELECT COALESCE(ROUND(AVG(rating)::numeric, 2), 0)
                FROM reviews
                WHERE food_id = @foodId
              )
            WHERE id = @foodId
            RETURNING rating_avg
          '''),
          parameters: {'foodId': review.foodId},
        );
        final newRatingAvg = ratingResult.first[0] as double?;
        return (insertedReview, newRatingAvg); // Trả về review mới tạo và rating của nó
      });
    } catch (e) {
      print("Error createReview: $e");
      return (null, null);
    }
  }

  Future<int> countReview(int foodId) async {
    final conn = await DatabaseConfig.connection();

    try {
      final result = await conn.execute(
        Sql.named("SELECT COUNT(*) FROM reviews WHERE food_id = @id"),
        parameters: {"id": foodId},
      );

      return result.first[0] as int;
    } catch (e) {
      print("Error countReview: $e");
      return 0;
    }
  }
}