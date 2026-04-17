import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/core/models/food.dart';
import 'package:frontend/core/models/user.dart';
import 'package:frontend/public_service/public_services.dart';
import 'package:frontend/core/models/category_food.dart';
import '../../services/manager_foods_services.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'add_food_guide.dart';


class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFood> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final PublicServices _publicServices = PublicServices();

  int? _selectedCategory;
  bool _isAvailable = true;
  PlatformFile? _imageBytes;

  bool isLoading = false;
  late String token;
  late int restaurantId;
  final ManagerFoodsServices managerFoodsServices = ManagerFoodsServices();

  List<CategoryFood> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadAllCategories();
    token = context.read<AuthProvider>().token!;
    restaurantId = context.read<AuthProvider>().user!.id!;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // QUAN TRỌNG cho web
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      setState(() {
        _imageBytes = file;
      });
    }
  }

    Future<void> _loadAllCategories() async {
    try {
      final categories = await _publicServices.getAllCategories();
      setState(() => _categories = categories);
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 768 && width < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Thêm món mới',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFoodGuide(),
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 1100 : 800),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 48 : 24,
                      vertical: 32,
                    ),
                    child: Card(
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'MÓN ĂN',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Tạo mới',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Thông tin chi tiết món ăn',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Điền đầy đủ thông tin để món ăn hiển thị đẹp trên ứng dụng',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 32),

                            // Layout 2 cột trên màn hình lớn
                            Flex(
                              direction: isDesktop ? Axis.horizontal : Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cột trái - Ảnh 
                                Expanded(
                                  flex: isDesktop ? 4 : 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildImageUploader(),
                                    ],
                                  ),
                                ),

                                if (isDesktop) const SizedBox(width: 48),

                                // Cột phải - Thông tin bổ sung
                                Expanded(
                                  flex: isDesktop ? 3 : 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isDesktop) const SizedBox(height: 32),

                                      const SizedBox(height: 32),
                                      _buildTextField(
                                        controller: _nameController,
                                        label: 'Tên món ăn',
                                        hint: 'Ví dụ: Phở bò tái nạm',
                                        required: true,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        controller: _priceController,
                                        label: 'Giá bán (VNĐ)',
                                        hint: '85,000',
                                        keyboardType: TextInputType.number,
                                        required: true,
                                      ),
                                      const SizedBox(height: 20),
                                      DropdownButtonFormField<int>(
                                        value: _selectedCategory,
                                        decoration: _inputDecoration('Danh mục'),
                                        items: _categories
                                            .map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)))
                                            .toList(),
                                        onChanged: (v) => setState(() => _selectedCategory = v),
                                        validator: (v) => v == null ? 'Vui lòng chọn danh mục' : null,
                                      ),
                                      const SizedBox(height: 20),

                                      const Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 12),

                                      _buildSwitchTile(
                                        title: 'Có sẵn để bán',
                                        value: _isAvailable,
                                        onChanged: (v) => setState(() => _isAvailable = v),
                                      ),

                                      const SizedBox(height: 32),

                                      TextFormField(
                                        controller: _descriptionController,
                                        minLines: 4,
                                        maxLines: null,
                                        decoration: _inputDecoration('Mô tả chi tiết').copyWith(
                                          hintText: 'Thành phần, cách ăn ngon, lưu ý dị ứng...',
                                          alignLabelWithHint: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 48),

                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Hủy'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: isLoading ? null : () => _submit(),
                                  icon: isLoading 
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2.5),
                                        )
                                      : const Icon(Icons.add_rounded, size: 20),
                                  label: Text(isLoading ? 'Đang thêm món ăn...' : 'Thêm món ăn'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                    backgroundColor: Colors.redAccent.shade700,
                                    foregroundColor: Colors.white,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('Ảnh đại diện', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(width: 6),
            Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              image: _imageBytes != null
                  ? DecorationImage(
                      image: MemoryImage(_imageBytes!.bytes!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _imageBytes == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_photo_alternate_rounded, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nhấn để chọn ảnh', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('(tỷ lệ đề xuất 4:3 hoặc 1:1)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label).copyWith(hintText: hint),
      validator: required
          ? (v) => v?.trim().isEmpty ?? true ? 'Trường này là bắt buộc' : null
          : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        activeColor: Colors.green.shade600,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onChanged: onChanged,
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO: xử lý upload ảnh + gọi API

    setState(() { 
      /* loading */
      isLoading = true;

     });
    final nameImageUrl = await managerFoodsServices.uploadImageFood(token,_imageBytes!);

    final newFood = Food(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      imageUrl: nameImageUrl,
      isAvailable: _isAvailable,
      categoryId: _selectedCategory!,
      restaurantId: restaurantId, 
    );

    final addedFood = await managerFoodsServices.addFood(token, newFood);

    setState(() => isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã thêm món ăn thành công!'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context, addedFood);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}