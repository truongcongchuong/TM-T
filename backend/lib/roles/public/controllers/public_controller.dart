import 'package:shelf/shelf.dart';
import '../../../core/utils/response.dart';
import 'package:backend/shared/services/public_service.dart';
import '../../../shared/services/reviews_service.dart';
import 'package:backend/shared/enum/payment_method_enum.dart';
import '../../../shared/services/payment_service.dart';
import '../../../shared/services/food_service.dart';

class PublicController {
  final PublicService publicService = PublicService();
  final ReviewsService reviewsService = ReviewsService();
  final PaymentService paymentService = PaymentService();
  final FoodService foodService = FoodService();

  Future<Response> getCategoryById(Request req, String categoryId) async {
    final id = int.tryParse(categoryId);

    if (id == null) {
      return ResponseUtil.badRequest(
        'categoryId không hợp lệ',
      );
    }

    final category = await publicService.getNameCategoryById(id);

    if (category == null) {
      return ResponseUtil.notFound(
        'Không tìm thấy category',
      );
    }

    return ResponseUtil.success({'name': category});
  }

  Future<Response> getAllCategories(Request req) async {
    final categories = await publicService.getAllCategories();
    return ResponseUtil.success(categories.map((c) => c.toMap()).toList());
  }

  Future<Response> getReviewsFood(Request req, String foodId) async {
    final id = int.tryParse(foodId);

    if (id == null) {
      return ResponseUtil.badRequest(
        'foodId không hợp lệ',
      );
    }

    final reviews = await reviewsService.getAllReviews(id);

    return ResponseUtil.success(reviews.map((r) => r.toMap()).toList());
  }

  Future<Response> getInfoUser(Request req, String userId) async {
    final id = int.tryParse(userId);

    if (id == null) {
      return ResponseUtil.badRequest(
        'userId không hợp lệ',
      );
    }

    final infoUser = await publicService.getInfoUser(id);

    if (infoUser == null) {
      return ResponseUtil.notFound(
        'Không tìm thấy thông tin người dùng',
      );
    }

    return ResponseUtil.success(infoUser.toMap());
  }

  Future<Response> countReviewsByFoodId(Request req, String foodIdStr) async {
    try {
      final foodId = int.tryParse(foodIdStr);
      if (foodId == null) {
        return ResponseUtil.badRequest('Invalid food ID');
      }

      ReviewsService reviewsService = ReviewsService();
      final count = await reviewsService.countReview(foodId);

      return ResponseUtil.success({'count': count});
    } catch (e) {
      return ResponseUtil.serverError('Failed to fetch review count: $e');
    }
  }

  Future<Response> getPaymentMethodId(Request rep, String methodPayment) async {
    try {
      MethodPayment method = MethodPayment.fromString(methodPayment);

      final result = await paymentService.getPaymentMethodId(method);

      return ResponseUtil.success(result);
    } catch (e) {
      print("lỗi $e");
      return ResponseUtil.badRequest('Không lấy được payment method');
    }
  }

  Future<Response> searchFoods(Request request) async {
    try {
      final query = request.url.queryParameters['query'] ?? '';

      if (query.trim().isEmpty) {
        return ResponseUtil.success([]);
      }

      final result = await foodService.searchFood(query);
      print(result.map((e) => e.toMap()).toList());

      return ResponseUtil.success(
        result.map((e) => e.toMap()).toList(),
      );

    } catch (e) {
      return ResponseUtil.serverError('Search failed: $e');
    }
  }
}