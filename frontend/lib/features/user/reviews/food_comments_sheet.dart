import 'package:flutter/material.dart';
import 'package:frontend/core/models/food.dart';
import 'package:frontend/core/models/review_model.dart';
import 'package:frontend/core/models/info_public_user.dart';
import 'package:frontend/features/user/services/reviews_service.dart';
import 'widgets/write_review_form.dart';

class FoodCommentsSheet extends StatefulWidget {
  final Food food;
  final ScrollController scrollController;
  final Function(double, int)? onRatingUpdated;

  const FoodCommentsSheet({
    super.key,
    required this.food,
    required this.scrollController,
    this.onRatingUpdated,
  });

  @override
  State<FoodCommentsSheet> createState() => _FoodCommentsSheetState();
}

class _FoodCommentsSheetState extends State<FoodCommentsSheet> {
  final ReviewsService reviewsService = ReviewsService();
  List<ReviewModel> reviews = [];
  bool isLoadingReviews = false;
  double ratingAvg = 0.0;

  @override
  void initState() {
    super.initState();
    loadReviews();
    ratingAvg = widget.food.ratingAvg!;
  }

  Future<void> loadReviews() async {
    setState(() => isLoadingReviews = true);
    try {
      final data = await reviewsService.getReviewsByFoodId(widget.food.id!);
      setState(() => reviews = data);
    } catch (e) {
      print("Lỗi khi tải đánh giá: $e");
    } finally {
      setState(() => isLoadingReviews = false);
    }
  }

  Future<InfoPublicUserModel?> loadUserInfo(int userId) async {
    try {
      return await reviewsService.getInfoUserById(userId);
    } catch (e) {
      print("Lỗi khi tải thông tin người dùng: $e");
      return null;
    }
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) return "${difference.inSeconds} giây trước";
    if (difference.inMinutes < 60) return "${difference.inMinutes} phút trước";
    if (difference.inHours < 24) return "${difference.inHours} giờ trước";
    if (difference.inDays < 7) return "${difference.inDays} ngày trước";
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text("Đánh giá & Bình luận",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("${ratingAvg.toStringAsFixed(2)} ⭐ (${reviews.length})",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),

        const Divider(height: 1),

        // Danh sách bình luận
        Expanded(
          child: isLoadingReviews
              ? const Center(child: CircularProgressIndicator())
              : reviews.isEmpty
                  ? const Center(child: Text("Chưa có đánh giá nào cho món ăn này"))
                  : ListView.builder(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return FutureBuilder<InfoPublicUserModel?>(
                          future: loadUserInfo(review.userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                  height: 80, child: Center(child: CircularProgressIndicator()));
                            }
                            return _buildCommentItem(review, snapshot.data);
                          },
                        );
                      },
                    ),
        ),

        // Form viết bình luận (tách riêng để tối ưu)
        WriteReviewForm(
          foodId: widget.food.id!,
          onReviewSubmitted: (ReviewModel newReview, double newRatingAvg) {
            setState(() {
              reviews.insert(0, newReview); // Thêm bình luận mới vào đầu danh sách
              ratingAvg = newRatingAvg;
              widget.onRatingUpdated?.call(newRatingAvg, reviews.length); // Gửi cả rating mới và tổng số đánh giá về parent
            });
          },
        ),
      ],
    );
  }

  Widget _buildCommentItem(ReviewModel review, InfoPublicUserModel? user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage("https://tse1.mm.bing.net/th/id/OIP.voJKNcMH2y0ExEJF6TGu0AHaJQ?pid=Api&P=0&h=180"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user?.userName ?? "Người dùng", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text("${review.rating} ⭐", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(timeAgo(review.createAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Text(review.comment, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}