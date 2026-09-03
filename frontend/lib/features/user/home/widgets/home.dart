import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/features/user/services/food_services.dart';
import 'package:frontend/features/user/profile/profile.dart';
import 'package:frontend/core/models/category_food.dart';
import 'package:frontend/core/models/food_response.dart';
import 'chatbox.dart';
import 'home_app_bar.dart';
import 'home_body.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final FoodService foodServices = FoodService();

  bool showChatBox = false;
  bool isLoading = true;

  List<FoodResponse> foods = [];
  List<FoodResponse> filteredFoods = [];
  List<CategoryFood> categories = [];

  String _searchQuery = '';
  Timer? _debounce; // 🔥 debounce

  @override
  void initState() {
    super.initState();
    _loadFoods();
    _loadCategories();
  }

  Future<void> _loadFoods() async {
    try {
      final result = await foodServices.getAllFoods();
      if (!mounted) return;

      setState(() {
        foods = result;
        filteredFoods = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading foods: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await foodServices.getAllCategories();
      if (!mounted) return;

      final CategoryFood allCategory = CategoryFood(id: 0, name: 'Tất cả');
      setState(() {
        categories = [allCategory, ...result];
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  // ==================== SEARCH ====================
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final q = query.toLowerCase().trim();

      if (!mounted) return;

      setState(() {
        _searchQuery = q;
      });

      if (q.isEmpty) {
        setState(() {
          filteredFoods = foods;
        });
        return;
      }

      final result = await foodServices.searchFood(q);

      if (!mounted) return;

      setState(() {
        filteredFoods = result;
      });
    });
  }

  void _onSearchSubmitted() async {
    if (_searchQuery.isNotEmpty) {
      final result = await foodServices.searchFood(_searchQuery);

      if (!mounted) return;

      setState(() {
        filteredFoods = result;
      });
    }
  }
  // ================================================

  @override
  void dispose() {
    _debounce?.cancel(); // tránh memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: HomeAppBar(
        isDesktop: isDesktop,
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
        onChatTap: () {
          setState(() => showChatBox = !showChatBox);
        },
        onSearchChanged: _onSearchChanged,
        onSearchSubmitted: _onSearchSubmitted,
      ),
      body: Stack(
        children: [
          HomeBody(
            isDesktop: isDesktop,
            categories: categories,
            foods: filteredFoods,
          ),
          if (showChatBox)
            Positioned(
              right: 24,
              bottom: 24,
              child: ChatBox(
                onClose: () => setState(() => showChatBox = false),
              ),
            ),
        ],
      ),
    );
  }
}