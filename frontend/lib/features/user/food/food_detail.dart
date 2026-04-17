import 'package:flutter/material.dart';
import 'package:frontend/core/models/food.dart';
import 'package:frontend/features/user/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/user/order/bill_preview.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/models/cart.dart';
import 'widgets/desktop_layout.dart';
import 'widgets/mobile_layout.dart';
import '../reviews/food_comments_sheet.dart';
import 'package:frontend/features/user/services/reviews_service.dart';
import 'package:frontend/features/user/services/food_services.dart';

class FoodDetailScreen extends StatefulWidget {
  final Food food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  List<Food> recommendFoods = [];
  final FoodService foodService = FoodService();
  final ReviewsService reviewsService = ReviewsService();

  int quantity = 1;
  double? newRating;
  double get rating => newRating ?? widget.food.ratingAvg ?? 0.0;
  double get totalPrice => widget.food.price * quantity;
  int totalComments = 0;

  @override
  void initState() {
    super.initState();
    _loadTotalComments();
    _loadSuggestedFoods();
  }

  Future<void> _loadTotalComments() async {
    try {
      final comments = await reviewsService.getReviewsByFoodId(widget.food.id!);
      setState(() => totalComments = comments.length);
    } catch (e) {
      print("Lỗi khi tải số lượng bình luận: $e");
    }
  }

  Future<void> _loadSuggestedFoods() async {
    try {
      final suggestions = await foodService.recommendFood(widget.food.id!);
      setState(() => recommendFoods = suggestions);
    } catch (e) {
      print("Lỗi load món gợi ý: $e");
    }
  }

  void _increase() => setState(() => quantity++);
  void _decrease() {
    if (quantity > 1) setState(() => quantity--);
  }

  void showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: FoodCommentsSheet(
              food: widget.food,
              scrollController: scrollController,
              onRatingUpdated: (rt, totalReviews) {
                setState(() {
                  newRating = rt;
                  totalComments = totalReviews;
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;
    String token = context.read<AuthProvider>().token!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(food.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.favorite_border), color: Colors.red, onPressed: () {}),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), shape: BoxShape.circle),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 26),
                  color: Colors.blue[700],
                  onPressed: () => showCommentsBottomSheet(context),
                ),
                if (totalComments > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text("$totalComments", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: isDesktop
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 12, offset: const Offset(0, -4), color: Colors.black.withOpacity(0.06))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final cart = context.read<CartProvider>();
                          final result = await cart.addFood(food, quantity, token);
                          if (result) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${food.name} x$quantity vào giỏ hàng'), backgroundColor: Colors.green));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm vào giỏ hàng thất bại'), backgroundColor: Colors.red));
                          }
                        },
                        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.red),
                        label: const Text('Thêm vào giỏ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          final userId = context.read<AuthProvider>().user!.id;
                          final itemcart = ItemCart(food: food, quantity: quantity);
                          Cart cart = Cart(userId: userId!, items: [itemcart]);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BillPreviewScreen(cart: cart)));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('ĐẶT MÓN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(width: 8),
                            Text('${totalPrice.toStringAsFixed(0)} đ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

      body: isDesktop
          ? FoodDetailDesktop(
              food: food.copyWith(ratingAvg: rating),
              quantity: quantity,
              totalComments: totalComments,
              totalPrice: totalPrice,
              onIncrease: _increase,
              onDecrease: _decrease,
              recommendFoods: recommendFoods,
            )
          : FoodDetailMobile(
              food: food.copyWith(ratingAvg: rating),
              quantity: quantity,
              totalComments: totalComments,
              totalPrice: totalPrice,
              onIncrease: _increase,
              onDecrease: _decrease,
              recommendFoods: recommendFoods,
            ),
    );
  }
}