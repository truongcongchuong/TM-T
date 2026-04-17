import 'package:flutter/material.dart';
import 'widgets/restaurant_sidebar.dart';
import 'package:frontend/features/restaurant/food_management/food_management.dart';
import 'widgets/dashboard.dart';
import 'package:frontend/features/restaurant/order_management/order_management.dart';
import 'package:frontend/features/restaurant/user_management/user_management.dart';
import 'package:frontend/features/restaurant/setting/setting.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    RestaurantFoodScreen(),
    OrderManagementPage(),
    UserManagementPage(),
    RestaurantSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: isDesktop
          ? Row(
              children: [
                RestaurantSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                ),
                Expanded(child: _pages[_selectedIndex]),
              ],
            )
          : _pages[_selectedIndex],
    );
  }
}

