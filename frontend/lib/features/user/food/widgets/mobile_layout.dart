import 'package:flutter/material.dart';
import 'recommend_food_section.dart';
import '../food_detail.dart';
import 'package:frontend/core/config/config.dart';
import 'package:frontend/core/models/food_response.dart';


class FoodDetailMobile extends StatelessWidget {
  final FoodResponse food;
  final int quantity;
  final int totalComments;
  final double totalPrice;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final List<FoodResponse> recommendFoods;
  final String distanceText;          // ← THÊM
  final bool isLoadingDistance;

  const FoodDetailMobile({
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh món ăn
          Image.network(
            "$baseUrl$pathImage${food.food.imageUrl}" ,
            width: double.infinity,
            height: 280,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 100),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.food.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${food.food.price} VNĐ', style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Icon(Icons.star_rounded, color: Colors.orange, size: 22),
                    Text(' ${food.food.ratingAvg ?? 0.0}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    Text(' ($totalComments)', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(food.food.description , style: const TextStyle(fontSize: 15.5, height: 1.5)),
              ],
            ),
          ),

          // Phần gợi ý món ăn
          RecommendFoodsSection(
            foods: recommendFoods,
            onFoodTap: (food) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)));
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}