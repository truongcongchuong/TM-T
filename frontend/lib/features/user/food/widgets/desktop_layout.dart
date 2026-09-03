import 'package:flutter/material.dart';
import 'package:frontend/core/config/config.dart';
import 'package:frontend/features/user/food/widgets/recommend_food_section.dart';
import 'package:frontend/features/user/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/user/order/bill_preview.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/models/cart.dart';
import 'package:frontend/features/user/food/food_detail.dart';
import 'package:frontend/core/models/food_response.dart';

class FoodDetailDesktop extends StatelessWidget {
  final FoodResponse food;
  final int quantity;
  final int totalComments;
  final double totalPrice;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final List<FoodResponse> recommendFoods;
  final String distanceText;
  final bool isLoadingDistance;

  const FoodDetailDesktop({
    super.key,
    required this.food,
    required this.quantity,
    required this.totalComments,
    required this.totalPrice,
    required this.onIncrease,
    required this.onDecrease,
    required this.recommendFoods,
    required this.distanceText,
    required this.isLoadingDistance,
  });

  @override
  Widget build(BuildContext context) {
    String token = context.read<AuthProvider>().token!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 620),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      /// LEFT: IMAGE
                      Expanded(
                        flex: 5,
                        child: Container(
                          color: Colors.black.withOpacity(0.04),
                          child: Image.network(
                            "$baseUrl$pathImage${food.food.imageUrl}",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      /// RIGHT: DETAILS
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thông tin nhà hàng + khoảng cách
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.store_outlined, color: Colors.grey, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          food.restaurant.name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          food.restaurant.address!,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: Colors.grey[600],
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Khoảng cách
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.red, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        distanceText,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                      if (isLoadingDistance)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 6),
                                          child: SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                food.food.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ===== ROW: GIÁ + ĐÁNH GIÁ + THỜI GIAN CHUẨN BỊ =====
                              Row(
                                children: [
                                  // Giá
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      formatCurrency(food.food.price),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Đánh giá
                                  Row(
                                    children: [
                                      Icon(Icons.star_rounded, color: Colors.orange.shade400, size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${food.food.ratingAvg ?? 0.0}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '($totalComments đánh giá)',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  // Thời gian chuẩn bị (MỚI THÊM)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.timer_outlined, color: Colors.blue, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Chuẩn bị ${food.food.preparationTime} phút',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Mô tả món ăn',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    food.food.description,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Phần số lượng và nút
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Số lượng',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Tổng: ${formatCurrency(totalPrice)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // ... (phần còn lại giữ nguyên)
                              Row(
                                children: [
                                  // Quantity buttons, Add to cart, Đặt món ngay
                                  // (giữ nguyên code của bạn)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove_circle_outline), color: Colors.red),
                                        SizedBox(
                                          width: 40,
                                          child: Center(
                                            child: Text(quantity.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        IconButton(onPressed: onIncrease, icon: const Icon(Icons.add_circle_outline), color: Colors.red),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final cart = context.read<CartProvider>();
                                          final result = await cart.addFood(food.food, quantity, token);
                                          if (result) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Đã thêm ${food.food.name} x$quantity vào giỏ hàng'),
                                                backgroundColor: Colors.green,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Thêm vào giỏ hàng thất bại'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.red),
                                        label: const Text('Thêm vào giỏ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.red),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final userId = context.read<AuthProvider>().user!.id;
                                          final itemcart = ItemCart(food: food.food, quantity: quantity);
                                          Cart cart = Cart(userId: userId!, items: [itemcart]);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => BillPreviewScreen(cart: cart)),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: const Text(
                                          'ĐẶT MÓN NGAY',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: RecommendFoodsSection(
              foods: recommendFoods,
              onFoodTap: (recommendedFood) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FoodDetailScreen(food: recommendedFood)),
                );
              },
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}