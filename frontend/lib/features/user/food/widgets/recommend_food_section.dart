import 'package:flutter/material.dart';
import 'package:frontend/core/models/food.dart';
import 'package:frontend/features/user/home/widgets/food_card.dart'; // Card món ăn bạn đang dùng

class RecommendFoodsSection extends StatelessWidget {
  final List<Food> foods;
  final Function(Food) onFoodTap;

  const RecommendFoodsSection({super.key, required this.foods, required this.onFoodTap});

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Món ăn gợi ý cùng bạn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 245,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 16),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: SizedBox(
                  width: 170,
                  child: FoodCard(
                    food: food
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}