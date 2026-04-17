import 'package:flutter/material.dart';
import 'package:frontend/core/models/cart.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/user/providers/cart_provider.dart';
import 'package:frontend/features/user/food/food_detail.dart';
import 'package:frontend/core/config/config.dart';
import 'package:frontend/features/user/order/bill_preview.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/auth/screens/login.dart';
import 'package:frontend/features/user/services/cart_service.dart';

class CartContent extends StatefulWidget {
  const CartContent({super.key});

  @override
  State<CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<CartContent> {
  Set<int> selectedItems = {}; // lưu id các món được chọn

  CartService cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.isEmpty) {
          return const Center(
            child: Text(
              'Giỏ hàng trống',
              style: TextStyle(fontSize: 20),
            ),
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final bool isDesktop = screenWidth >= 900;

        // Tính tổng tiền các món đã chọn
        final selectedTotal = cart.items
            .where((item) => selectedItems.contains(item.food.id))
            .fold<double>(
              0,
              (sum, item) => sum + item.food.price * item.quantity,
            );

        return Container(
          color: const Color(0xFFF5F5F7),
          child: Column(
            children: [
              // GRIDVIEW: danh sách món trong giỏ
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : 2,
                    childAspectRatio: isDesktop ? 0.8 : 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.items[index];
                    final food = cartItem.food;
                    final isSelected = selectedItems.contains(food.id);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FoodDetailScreen(food: food),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shadowColor: Colors.black.withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      "$baseUrl$pathImage${food.imageUrl}",
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // DELETE
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      radius: 18,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          String token = context.read<AuthProvider>().token!;
                                          cartService.removeItemCart(token, food.id! );
                                          cart.removeFood(food.id!);
                                          
                                          setState(() {
                                            selectedItems.remove(food.id);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  // CHECKBOX
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value == true) {
                                                  selectedItems.add(food.id!);
                                                } else {
                                                  selectedItems.remove(food.id);
                                                }
                                              });
                                            },
                                            activeColor: Colors.red,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          const Text(
                                            'Chọn',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    food.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${food.price} VNĐ',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Số lượng: ${cartItem.quantity}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // NÚT “ĐẶT MÓN” + tổng tiền bên dưới
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Tổng thanh toán',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${selectedTotal.toStringAsFixed(0)} VNĐ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: isDesktop ? 220 : 160,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final auth = context.read<AuthProvider>();
                          final userID = auth.user!.id;

                          if (userID == null) {
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                            return;
                          }

                          final itemList = cart.items
                              .where((item) =>
                                  selectedItems.contains(item.food.id))
                              .toList();

                          if (itemList.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Vui lòng chọn ít nhất 1 món')),
                            );
                            return;
                          }

                          Cart selectFood =
                              Cart(userId: userID, items: itemList);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BillPreviewScreen(cart: selectFood),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ĐẶT MÓN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
