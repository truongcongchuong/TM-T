import 'package:flutter/material.dart';
import 'package:frontend/core/models/food.dart';
import 'package:frontend/core/config/config.dart';
import 'package:frontend/features/user/food/widgets/recommend_food_section.dart';
import 'package:frontend/features/user/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/user/order/bill_preview.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/models/cart.dart';
import 'package:frontend/features/user/food/food_detail.dart'; // FoodDetailScreen

class FoodDetailDesktop extends StatelessWidget {
  final Food food;
  final int quantity;
  final int totalComments;
  final double totalPrice;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final List<Food> recommendFoods;

  const FoodDetailDesktop({
    super.key,
    required this.food,
    required this.quantity,
    required this.totalComments,
    required this.totalPrice,
    required this.onIncrease,
    required this.onDecrease,
    required this.recommendFoods,
  });

  @override
  Widget build(BuildContext context) {
    String token = context.read<AuthProvider>().token!;

    return SingleChildScrollView(   // ← Fix lỗi unbounded constraints
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
                            "$baseUrl$pathImage${food.imageUrl}",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: Colors.grey,
                              ),
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
                              Text(
                                food.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
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
                                      '${food.price} VNĐ',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.orange.shade400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${food.ratingAvg ?? 0.0}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '($totalComments đánh giá)',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Mô tả món ăn',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    food.description,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Số lượng',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Tổng: ${totalPrice.toStringAsFixed(0)} VNĐ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
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
                                        IconButton(
                                          onPressed: onDecrease,
                                          icon: const Icon(Icons.remove_circle_outline),
                                          color: Colors.red,
                                        ),
                                        SizedBox(
                                          width: 40,
                                          child: Center(
                                            child: Text(
                                              quantity.toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: onIncrease,
                                          icon: const Icon(Icons.add_circle_outline),
                                          color: Colors.red,
                                        ),
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
                                          final result = await cart.addFood(food, quantity, token);
                                          if (result) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Đã thêm ${food.name} x$quantity vào giỏ hàng'),
                                                backgroundColor: Colors.green,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Thêm vào giỏ hàng thất bại'),
                                                backgroundColor: Colors.red,
                                                behavior: SnackBarBehavior.floating,
                                              ),
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
                                          final itemcart = ItemCart(food: food, quantity: quantity);
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

          // ==================== PHẦN GỢI Ý MÓN ĂN ====================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: RecommendFoodsSection(
              foods: recommendFoods,
              onFoodTap: (recommendedFood) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodDetailScreen(food: recommendedFood),
                  ),
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