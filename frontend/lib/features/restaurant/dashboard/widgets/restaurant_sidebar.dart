import 'package:flutter/material.dart';

class RestaurantSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const RestaurantSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.restaurant_menu,
              size: 40, color: Colors.red),
          const SizedBox(height: 8),
          const Text(
            'Restaurant Panel',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 32),

          _menuItem(0, Icons.dashboard, 'Dashboard'),
          _menuItem(1, Icons.fastfood, 'Quản lý món ăn'),
          _menuItem(2, Icons.receipt_long, 'Đơn hàng'),
          _menuItem(3, Icons.people, 'Người dùng'),
          _menuItem(4, Icons.settings, 'Cài đặt'),
        ],
      ),
    );
  }

  Widget _menuItem(int index, IconData icon, String title) {
    final bool active = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.red.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.red : Colors.black54),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: active ? Colors.red : Colors.black87,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
