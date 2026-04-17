import 'package:flutter/material.dart';
import 'package:frontend/core/models/review_model.dart';
import 'package:frontend/features/user/services/reviews_service.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class WriteReviewForm extends StatefulWidget {
  final int foodId;
  final Function(ReviewModel, double) onReviewSubmitted;   // ← Đổi thành nhận ReviewModel

  const WriteReviewForm({
    super.key,
    required this.foodId,
    required this.onReviewSubmitted,
  });

  @override
  State<WriteReviewForm> createState() => _WriteReviewFormState();
}

class _WriteReviewFormState extends State<WriteReviewForm> {
  int _userRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final ReviewsService reviewsService = ReviewsService();
  late String token;

  @override
  void initState() {
    super.initState();
    token = context.read<AuthProvider>().token!;
  }

  Future<void> _submitReview() async {
    if (_userRating == 0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao và viết bình luận'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (context.read<AuthProvider>().user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để gửi đánh giá'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      ReviewModel newReview = ReviewModel(
        id: 0, // backend sẽ trả về id thật
        userId: context.read<AuthProvider>().user!.id!, // Lấy userId từ AuthProvider
        foodId: widget.foodId,
        rating: _userRating,
        comment: _commentController.text.trim(),
        createAt: DateTime.now(),
      );

      final result = await reviewsService.createReview(newReview, token);

      if (result.$1 == null || result.$2 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi đánh giá thất bại'), backgroundColor: Colors.red),
        );
        return;
      }

      // Nếu API trả về object ReviewModel đã có id và thông tin đầy đủ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đánh giá đã được gửi thành công!'), backgroundColor: Colors.green),
      );

      // Reset form
      _commentController.clear();
      setState(() => _userRating = 0);

      // Truyền review mới về parent để thêm vào list
      widget.onReviewSubmitted(result.$1!, result.$2!); // Gửi cả ReviewModel và rating mới về parent

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... giữ nguyên phần build như cũ
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Chọn sao
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _userRating = index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    index < _userRating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 38,
                    color: index < _userRating ? Colors.amber : Colors.grey.shade400,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Ô nhập comment
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage("https://tse1.mm.bing.net/th/id/OIP.voJKNcMH2y0ExEJF6TGu0AHaJQ?pid=Api&P=0&h=180"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Viết bình luận của bạn...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.red, size: 28),
                onPressed: _submitReview,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}