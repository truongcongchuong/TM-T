import 'package:flutter/material.dart';
import 'package:frontend/core/models/food.dart';
import 'package:frontend/core/models/category_food.dart';
import 'package:frontend/features/user/services/food_services.dart';
import 'food_card.dart';

class HomeBody extends StatefulWidget {
  final bool isDesktop;
  final List<CategoryFood> categories;
  final List<Food> foods;           // Danh sách từ parent (search/filter)
  final String? searchQuery;        // Thêm để hiển thị tiêu đề

  const HomeBody({
    super.key,
    required this.isDesktop,
    required this.categories,
    required this.foods,
    this.searchQuery,
  });

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  int selectedCategoryIndex = 0;
  List<Food> currentFoods = [];
  final FoodService foodService = FoodService();

  @override
  void initState() {
    super.initState();
    currentFoods = widget.foods;
  }

  // Quan trọng: Cập nhật khi parent truyền danh sách mới (search)
  @override
  void didUpdateWidget(covariant HomeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.foods != widget.foods) {
      setState(() {
        currentFoods = widget.foods;
        // Reset category về "Tất cả" khi search
        if (widget.searchQuery?.isNotEmpty == true) {
          selectedCategoryIndex = 0;
        }
      });
    }
  }

  Future<void> fetchFoodsByCategory(int categoryId) async {
    try {
      if (categoryId == 0) {
        // "Tất cả"
        setState(() {
          currentFoods = widget.foods; // Dùng lại danh sách từ parent
        });
        return;
      }

      final response = await foodService.getFoodsByCategory(categoryId);
      setState(() {
        currentFoods = response;
      });
    } catch (e) {
      debugPrint('Error loading foods by category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildHeader(),
        _buildFoodGrid(),
      ],
    );
  }

  // ================= HEADER =================
  SliverToBoxAdapter _buildHeader() {
    final bool isSearching = widget.searchQuery?.isNotEmpty == true;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isDesktop ? 32 : 16,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSearching 
                  ? 'Kết quả tìm kiếm cho "${widget.searchQuery}"'
                  : (widget.isDesktop ? 'Xin chào, hôm nay ăn gì?' : 'Gợi ý cho bạn'),
              style: TextStyle(
                fontSize: widget.isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching 
                  ? '${currentFoods.length} món ăn được tìm thấy'
                  : 'Khám phá các món ăn phổ biến và được yêu thích.',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategories(),
          ],
        ),
      ),
    );
  }

  // ================= CATEGORIES =================
  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bool isSelected = index == selectedCategoryIndex;
          final category = widget.categories[index];

          return GestureDetector(
            onTap: () async {
              setState(() {
                selectedCategoryIndex = index;
              });
              await fetchFoodsByCategory(category.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Text(
                category.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.red,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= FOOD GRID =================
  SliverPadding _buildFoodGrid() {
    if (currentFoods.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(32),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.search_off, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  widget.searchQuery?.isNotEmpty == true 
                      ? 'Không tìm thấy món ăn nào' 
                      : 'Chưa có món ăn nào',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 32 : 24,
        vertical: 8,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return FoodCard(food: currentFoods[index]);
          },
          childCount: currentFoods.length,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: widget.isDesktop ? 300 : 260,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: widget.isDesktop ? 0.78 : 0.72,
        ),
      ),
    );
  }
}