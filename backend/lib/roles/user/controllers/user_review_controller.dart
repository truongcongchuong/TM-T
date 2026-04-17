import 'package:shelf/shelf.dart';
import '../../../core/utils/response.dart';
import 'dart:convert';
import '../../../shared/services/reviews_service.dart';
import 'package:backend/shared/enum/user_role_enum.dart';
import '../../../shared/models/review_model.dart';

class UserReviewController {
  Future<Response> createReview(Request req) async {
    try {
      ReviewsService reviewsService = ReviewsService();
        
      if (req.context['userId'] == null || req.context['role'] != UserRoleEnum.user.value) {
        return ResponseUtil.unauthorized();
      }
      final body = await req.readAsString();
      if (body.isEmpty) {
        return ResponseUtil.badRequest('Request body is empty');
      }

      final data = jsonDecode(body);
      final review = ReviewModel.fromJson(data);

      var result = await reviewsService.createReview(review);

      if (result.$1 == null || result.$2 == null) {
        return ResponseUtil.badRequest('Failed to create review');
      }

      return ResponseUtil.success({
        'review': result.$1!.toMap(),
        'rating_avg': result.$2
      });
  
    } catch (e) {
      return ResponseUtil.badRequest('Invalid request body: $e');
    }
  }
}
