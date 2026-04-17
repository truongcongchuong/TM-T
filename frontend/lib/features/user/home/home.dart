import 'package:flutter/material.dart';
import './widgets/home.dart'; // HomePageContent
import 'package:frontend/features/user/cart/cart.dart';
import 'package:frontend/features/user/order/history_order.dart';
import 'package:frontend/features/user/nontification/nontification.dart';
import 'package:frontend/features/user/setting/setting.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const HistoryOrderScreen(),
    const CartContent(),
    const NotificationScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              backgroundColor: Colors.white,
              elevation: 4,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.fastfood, size: 36, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Food App', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Trang chủ')),
                NavigationRailDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list), label: Text('Lịch sử')),
                NavigationRailDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: Text('Giỏ hàng')),
                NavigationRailDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: Text('Thông báo')),
                NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Cài đặt')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _pages[_selectedIndex],   // ← Sửa thành này
            ),
          ],
        ),
      );
    }

    // Mobile
    return Scaffold(
      body: _pages[_selectedIndex],           // ← Sửa thành này
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 246, 212, 209),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lịch sử'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}