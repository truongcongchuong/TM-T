import 'package:frontend/core/config/config.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/food.dart';
import 'package:frontend/features/restaurant/services/manager_foods_services.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/public_service/public_services.dart';
import './widgets/add_food.dart';
import './widgets/edit_food.dart';

class RestaurantFoodScreen extends StatefulWidget {
  const RestaurantFoodScreen({super.key});

  @override
  State<RestaurantFoodScreen> createState() => _RestaurantFoodScreenState();
}

class _RestaurantFoodScreenState extends State<RestaurantFoodScreen> {
  List<Food> foods = [];
  final PublicServices publicServices = PublicServices();
  final ManagerFoodsServices managerFoodsServices = ManagerFoodsServices();
  late String token;

  @override
  void initState() {
    super.initState();
    token = context.read<AuthProvider>().token!;
    _loadFoods(token);
  }

  Future<void> _loadFoods(String token) async {
    try {
      final foodsList = await ManagerFoodsServices().getFoods(token);
      setState(() {
        foods = foodsList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load foods')),
      );
    }
  }

  void _updateFoodInList(Food? updatedFood) {
    if (updatedFood == null) return;

    setState(() {
      // Tìm vị trí món ăn cũ trong danh sách dựa vào ID
      int index = foods.indexWhere((f) => f.id == updatedFood.id);
      
      if (index != -1) {
        // Thay thế phần tử cũ bằng phần tử mới nhận từ server
        foods[index] = updatedFood;
      }
    });
  }

  void _confirmDelete(int foodId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa món ăn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await managerFoodsServices.deleteFood(token, foodId);

      if (result) {
        setState(() {
          foods.removeWhere((food) => food.id == foodId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa món ăn thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa món ăn thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: const Text('Quản lý món ăn'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFood(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm món'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: isDesktop
                  ? _buildTable()
                  : _buildMobileList(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm món ăn...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= DESKTOP TABLE =================
  Widget _buildTable() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: DataTable(
          headingRowHeight: 56,
          dataRowHeight: 64,
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Hình ảnh')),
            DataColumn(label: Text('Tên món')),
            DataColumn(label: Text('Giá')),
            DataColumn(label: Text('Trạng thái')),
            DataColumn(label: Text('Điểm đánh giá')),
            DataColumn(label: Text('Loại món')),
            DataColumn(label: Text('Hành động')),
          ],
          rows: foods.map((food) {
            return DataRow(cells: [
              DataCell(Text(food.id.toString())),
              DataCell(Image.network(
                '$baseUrl$pathImage${food.imageUrl}',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )),
              DataCell(Text(food.name)),
              DataCell(Text('${food.price} VNĐ')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: food.isAvailable!
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    food.isAvailable! ? 'Đang bán' : 'Ngừng bán',
                    style: TextStyle(
                      color: food.isAvailable! ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(Text(food.ratingAvg != null ? food.ratingAvg!.toStringAsFixed(1) : 'Chưa có đánh giá')),
              DataCell(
                FutureBuilder<String?>(
                  future: publicServices.getNameCategoryById(food.categoryId!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading...');
                    }
                    final category = snapshot.data!;
                    return Text(category);
                  },
                ),
              ),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async{
                      final  result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditFood(
                            foodData: food,
                          ),
                        ),
                      );

                      if (result != null && result is Food) {
                        _updateFoodInList(result);
                      }

                      if (result != null && result is bool && result == true) {
                        setState(() {
                          foods.removeWhere((f) => f.id == food.id);
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(food.id!);
                    },
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // ================= MOBILE LIST =================
  Widget _buildMobileList() {
    return ListView.separated(
      itemCount: foods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final food = foods[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ===== IMAGE =====
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '$baseUrl$pathImage${food.imageUrl}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              // ===== INFO =====
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      food.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Price
                    Text(
                      '${food.price} VNĐ',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Status + Rating
                    Row(
                      children: [
                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: food.isAvailable!
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            food.isAvailable! ? 'Còn hàng' : 'Hết hàng',
                            style: TextStyle(
                              fontSize: 12,
                              color: food.isAvailable!
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Rating
                        if (food.ratingAvg != null)
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.orange),
                              const SizedBox(width: 2),
                              Text(
                                food.ratingAvg!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Category
                    Text(
                      publicServices
                          .getNameCategoryById(food.categoryId!)
                          .toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // ===== ACTION =====
              PopupMenuButton(
                onSelected: (value) async{
                  if (value == 'edit') {
                    // TODO: edit
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditFood(foodData: food),
                        ),
                      );
                      if (result != null && result is Food) {
                        _updateFoodInList(result);
                      }// Load lại dữ liệu
                    }
                  } else if (value == 'delete') {
                    // TODO: delete
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Sửa'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Xóa'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
