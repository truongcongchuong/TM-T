import 'package:shelf/shelf.dart';
import '../../../core/utils/response.dart';
import 'package:backend/shared/services/recommend_service.dart';

class PublicRecommendController {
  final RecommendService _service = RecommendService();

  Future<Response> getRecommendations(Request request, String foodId) async {
    try {

      final id = int.parse(foodId);

      final result = await _service.getRecommendations(id);

      return ResponseUtil.success(result.map((food) => food.toMap()).toList());
    } catch (e) {
      return ResponseUtil.serverError('Failed to get recommendations: $e');
    }
  }
}