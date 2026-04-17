import 'package:flutter/material.dart';
import 'package:frontend/core/models/food.dart';
import 'package:frontend/public_service/public_services.dart';
import 'package:frontend/core/models/category_food.dart';
import 'package:frontend/core/config/config.dart';
import 'package:frontend/features/restaurant/services/manager_foods_services.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class EditFood extends StatefulWidget {
  final Food foodData; // Dữ liệu món ăn nhận từ màn trước

  const EditFood({
    super.key,
    required this.foodData,
  });

  @override
  State<EditFood> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFood> {
  final ManagerFoodsServices _managerFoodsServices = ManagerFoodsServices();
  final _formKey = GlobalKey<FormState>();
  final PublicServices _publicServices = PublicServices();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  late String _token; 

  int? _selectedCategory;
  bool _isAvailable = true;
  String? _currentImageUrl; // URL ảnh hiện tại từ server
  PlatformFile? _imageBytes; // File ảnh mới nếu người dùng chọn upload
  late String? nameCategory; // đường dẫn ảnh mới nếu người dùng chọn upload

  List<CategoryFood> _categories = []; // Danh sách category để dropdown
  bool _isLoading = false;

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

  @override
  void initState() {
    super.initState();
    _loadAllCategories(); // Load tất cả category để hiển thị dropdown

    _token = context.read<AuthProvider>().token!;
    // Khởi tạo giá trị từ dữ liệu cũ
    _nameController = TextEditingController(text: widget.foodData.name);
    _priceController = TextEditingController(text: widget.foodData.price.toString());
    _descriptionController = TextEditingController(text: widget.foodData.description);

    _selectedCategory = widget.foodData.categoryId;
    _isAvailable = widget.foodData.isAvailable ?? true;
    _currentImageUrl = widget.foodData.imageUrl; // giả sử backend trả về url
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Chỉnh sửa món ăn',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: 'Xóa món ăn',
            onPressed: _confirmDelete,
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
                                    color: const Color(0xFFFEF3F2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'CHỈNH SỬA',
                                    style: TextStyle(
                                      color: Colors.redAccent.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Món: ${widget.foodData.name}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Cập nhật thông tin món ăn',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 32),

                            Flex(
                              direction: isDesktop ? Axis.horizontal : Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cột trái
                                Expanded(
                                  flex: isDesktop ? 4 : 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildImageUploader(),
                                      const SizedBox(height: 32),
                                    ],
                                  ),
                                ),

                                if (isDesktop) const SizedBox(width: 48),

                                // Cột phải
                                Expanded(
                                  flex: isDesktop ? 3 : 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isDesktop) const SizedBox(height: 32),

                                      _buildTextField(
                                        controller: _nameController,
                                        label: 'Tên món ăn',
                                        required: true,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        controller: _priceController,
                                        label: 'Giá bán (VNĐ)',
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
                                        maxLines: 5,
                                        minLines: 4,
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
                                  onPressed: _isLoading ? null : () => _submitUpdate(_token, _imageBytes), // truyền file ảnh mới nếu có
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2.5),
                                        )
                                      : const Icon(Icons.save_rounded, size: 20),
                                  label: Text(_isLoading ? 'Đang lưu...' : 'Lưu thay đổi'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                    backgroundColor: Colors.redAccent.shade700,
                                    foregroundColor: Colors.white,
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
    final hasCurrentImage = _currentImageUrl != null && _currentImageUrl!.isNotEmpty;
    final hasNewImage = _imageBytes != null;

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
              image: hasNewImage
                  ? DecorationImage(
                      image: MemoryImage(_imageBytes!.bytes!), // 🔥 preview ảnh mới
                      fit: BoxFit.cover,
                    )
                  : (hasCurrentImage
                      ? DecorationImage(
                          image: NetworkImage("$baseUrl$pathImage$_currentImageUrl"),
                          fit: BoxFit.cover,
                        )
                      : null),
            ),
            child: (!hasNewImage && !hasCurrentImage)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_photo_alternate_rounded, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nhấn để thay ảnh mới', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : (hasCurrentImage && !hasNewImage)
                    ? Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Ảnh hiện tại',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      )
                    : null,
          ),
        ),
        if (hasCurrentImage && !hasNewImage)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Bạn có thể thay bằng ảnh mới bằng cách nhấn vào vùng ảnh',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
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
        borderSide: BorderSide(color: Colors.redAccent.shade400, width: 2),
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

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa món ăn?'),
        content: const Text(
          'Món ăn sẽ bị xóa vĩnh viễn khỏi menu và không thể khôi phục. Bạn có chắc chắn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: gọi API xóa món
      setState(() => _isLoading = true);
      final bool isDeleted = await _managerFoodsServices.deleteFood(_token, widget.foodData.id!);
      setState(() => _isLoading = false);
      if (!isDeleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa món ăn thất bại')),
        );
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa món ăn')),
      );

      Navigator.pop(context, widget.foodData.id); // quay về danh sách, trả về null để biết là đã xóa
    }
  }

  Future<void> _submitUpdate(String token, PlatformFile? image) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String ? newImageUrl; // đường dẫn ảnh mới nếu người dùng chọn upload
    // TODO: xử lý upload ảnh mới nếu có (_newImagePath)
    if (image != null) {
      newImageUrl = await _managerFoodsServices.uploadImageFood(token,image);
    }
    // TODO: gọi API update với dữ liệu form

    final updateFood = widget.foodData.copyWith(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? widget.foodData.price,
      description: _descriptionController.text.trim(),
      isAvailable: _isAvailable,
      categoryId: _selectedCategory,// giữ nguyên nếu không đổi ảnh
      
    );
    print("data gửi lên api: ${updateFood.toJson()}");

    final Food? newInfoFood = await _managerFoodsServices.editFood(token, updateFood, newImageUrl);

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã cập nhật món ăn thành công'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context, newInfoFood); // quay về danh sách
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}