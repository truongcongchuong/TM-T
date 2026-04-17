import 'package:flutter/material.dart';
import 'package:frontend/core/models/bill.dart';
import 'package:frontend/core/models/food.dart';
import 'package:frontend/features/user/services/food_services.dart';
import 'package:frontend/core/config/config.dart';

class HistoryOrderCard extends StatefulWidget {
  final Bill bill;

  const HistoryOrderCard({
    super.key,
    required this.bill,
  });

  @override
  State<HistoryOrderCard> createState() => _HistoryOrderCardState();
}

class _HistoryOrderCardState extends State<HistoryOrderCard> {
  List<Food> foods = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    try {
      final foodService = FoodService();

      final futures = widget.bill.items
          .map((item) => foodService.getFoodById(item.foodId))
          .toList();

      final fetchedFoods = await Future.wait(futures);

      if (!mounted) return;

      setState(() {
        foods = fetchedFoods;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading foods: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  double get total {
    if (foods.length != widget.bill.items.length) return 0;

    double sum = 0;
    for (int i = 0; i < widget.bill.items.length; i++) {
      sum += foods[i].price * widget.bill.items[i].quantity;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: 12,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mã hóa đơn #${widget.bill.id}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${total.toStringAsFixed(0)} VNĐ',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: const Text(
          'Nhấn để xem chi tiết',
          style: TextStyle(fontSize: 12),
        ),
        children: List.generate(
          widget.bill.items.length,
          (index) {
            final item = widget.bill.items[index];
            final food = foods[index];

            return Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh bên trái
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "$baseUrl$pathImage${food.imageUrl}",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Nội dung bên phải (dọc)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          food.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'x${item.quantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '${(food.price * item.quantity).toStringAsFixed(0)} VNĐ',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
