import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/config/config.dart';
import 'package:frontend/core/models/info_public_user.dart';
import 'package:frontend/core/models/review_model.dart';

class ReviewsService {

  Future<List<ReviewModel>> getReviewsByFoodId(int foodId) async {
    final url = Uri.parse('$baseUrl/public/reviews/$foodId');
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body)["data"];
        print( "Reviews data: $jsonData"); // Debug: In dữ liệu nhận được
        return jsonData.map((item) => ReviewModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  Future<InfoPublicUserModel?> getInfoUserById(int userId) async {
    final url = Uri.parse('$baseUrl/public/userInfo/$userId');
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body)["data"];
        return InfoPublicUserModel.fromMap(jsonData);
      } else {
        throw Exception('Failed to load user info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user info: $e');
      return null;
    }
  }

  Future<(ReviewModel?, double?)> createReview(ReviewModel review, String token) async {
    final url = Uri.parse('$baseUrl/user/reviews');
    try {
      final response = await http.post(
        url,
        headers: {
          ...headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(review.toMap()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body)["data"];
        return (ReviewModel.fromJson(jsonData["review"]), jsonData["rating_avg"] as double?);
      } else {
        print('Failed to create review: ${response.statusCode}, ${response.body}');
        return (null, null);
      }
    } catch (e) {
      print('Error creating review: $e');
      return (null, null);
    }
  }

  Future<int> getTotalCommentsByFoodId(int foodId) async {
    final url = Uri.parse('$baseUrl/public/reviews/count/$foodId');
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData["data"] as int;
      } else {
        throw Exception('Failed to load total comments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching total comments: $e');
      return 0;
    }
  }
}