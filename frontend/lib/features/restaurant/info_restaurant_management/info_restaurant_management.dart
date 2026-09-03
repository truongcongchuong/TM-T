import 'package:flutter/material.dart';
import 'package:frontend/core/models/restaurant.dart';
import 'package:frontend/features/restaurant/services/manager_info_restaurant_service.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class RestaurantInfoPage extends StatefulWidget {
  const RestaurantInfoPage({super.key});

  @override
  State<RestaurantInfoPage> createState() => _RestaurantInfoPageState();
}

class _RestaurantInfoPageState extends State<RestaurantInfoPage> {
  RestaurantModel? restaurant;
  RestaurantModel? originalRestaurant;

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  bool isOpen = false;
  bool isEditing = false;
  bool isLoading = false;
  String? error;
  String? token;

  final ManagerInfoRestaurantServices managerInfoService =
      ManagerInfoRestaurantServices();

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    // init rỗng tránh crash
    nameController = TextEditingController();
    addressController = TextEditingController();
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      token = auth.token;

      loadInfoRestaurant(token);
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  // ================= LOAD API =================
  Future<void> loadInfoRestaurant(String? token) async {
    if (token == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await managerInfoService.getInfoRestaurant(token);

      setState(() {
        restaurant = data;
        originalRestaurant = data;

        _syncControllers(data);
      });
    } catch (e) {
      setState(() {
        error = "Không thể tải dữ liệu: $e";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // ================= SYNC CONTROLLER =================
  void _syncControllers(RestaurantModel data) {
    nameController.text = data.name;
    addressController.text = data.address ?? '';
    latitudeController.text = data.latitude?.toString() ?? '';
    longitudeController.text = data.longitude?.toString() ?? '';
    isOpen = data.isOpen;
  }

  // ================= SAVE =================
  void _saveChanges() async {
    if (restaurant == null || token == null) return;

    final updatedRestaurant = restaurant!.copyWith(
      name: nameController.text,
      address: addressController.text.isEmpty
          ? null
          : addressController.text,
      latitude: latitudeController.text.isEmpty
          ? null
          : double.tryParse(latitudeController.text),
      longitude: longitudeController.text.isEmpty
          ? null
          : double.tryParse(longitudeController.text),
      isOpen: isOpen,
    );

    final result = await managerInfoService.updateInfoRestaurant(
      updatedRestaurant,
      token!,
    );

    if (!result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thất bại')),
      );
      return;
    }

    setState(() {
      restaurant = updatedRestaurant;
      originalRestaurant = updatedRestaurant;
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật thông tin nhà hàng')),
    );
  }

  // ================= CANCEL =================
  void _cancelEdit() {
    if (originalRestaurant == null) return;

    setState(() {
      restaurant = originalRestaurant;
      _syncControllers(originalRestaurant!);
      isEditing = false;
    });
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (restaurant == null) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    final r = restaurant!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _row("Mã nhà hàng", r.id.toString()),
                        const Divider(),
                        _row("Mã chủ nhà hàng", r.owner.toString()),
                        const Divider(),
                        _field("Tên nhà hàng", nameController),
                        const Divider(),
                        _field("Địa chỉ", addressController),
                        const Divider(),
                        _latLng(),
                        const Divider(),
                        _switch(),
                        const Divider(),
                        _row("Rating", "${r.ratingAvg} ★"),
                        const Divider(),
                        _row("Ngày tạo", formatDate(r.createdAt)),
                        const SizedBox(height: 24),
                        _actions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGETS =================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Thông tin nhà hàng",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (!isEditing)
          ElevatedButton.icon(
            onPressed: () => setState(() => isEditing = true),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: Text(
              'Sửa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: Colors.white
              ),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 140, child: Text(label)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          readOnly: !isEditing,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _latLng() {
    return Row(
      children: [
        Expanded(child: _field("Vĩ độ", latitudeController)),
        const SizedBox(width: 10),
        Expanded(child: _field("Kinh độ", longitudeController)),
      ],
    );
  }

  Widget _switch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Mở cửa"),
        Switch(
          value: isOpen,
          onChanged:
              isEditing ? (v) => setState(() => isOpen = v) : null,
        ),
      ],
    );
  }

  Widget _actions() {
    if (!isEditing) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelEdit,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text(
              "Hủy",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 3,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Lưu thay đổi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}