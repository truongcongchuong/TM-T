import 'package:flutter/material.dart';

class AddFoodGuide extends StatelessWidget {
  const AddFoodGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Hướng dẫn sử dụng',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'HƯỚNG DẪN',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.help_outline_rounded,
                            size: 32, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Hướng dẫn thêm món ăn mới',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đọc kỹ hướng dẫn dưới đây để thêm món ăn nhanh chóng và đúng chuẩn.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Các phần hướng dẫn
                    _buildSection(
                      icon: Icons.photo_camera_outlined,
                      title: '1. Chọn ảnh đại diện',
                      content:
                          'Nhấn vào khung ảnh lớn để chọn ảnh từ thiết bị.\n'
                          '• Khuyến nghị tỷ lệ 4:3 hoặc 1:1\n'
                          '• Ảnh nên rõ nét, hấp dẫn, có ánh sáng tốt\n'
                          '• Dung lượng ảnh nên dưới 5MB',
                    ),

                    const SizedBox(height: 32),

                    _buildSection(
                      icon: Icons.edit_note_rounded,
                      title: '2. Nhập thông tin món ăn',
                      content:
                          '• Tên món ăn: Ví dụ "Phở bò tái nạm", "Cơm gà xối mắm"\n'
                          '• Giá bán: Nhập số nguyên (ví dụ: 85000)\n'
                          '• Danh mục: Chọn danh mục phù hợp (bắt buộc)',
                    ),

                    const SizedBox(height: 32),

                    _buildSection(
                      icon: Icons.toggle_on_rounded,
                      title: '3. Trạng thái món ăn',
                      content:
                          'Bật "Có sẵn để bán" nếu món đang kinh doanh bình thường.\n'
                          'Tắt nếu món tạm hết hoặc không muốn hiển thị.',
                    ),

                    const SizedBox(height: 32),

                    _buildSection(
                      icon: Icons.description_outlined,
                      title: '4. Mô tả chi tiết (khuyến khích)',
                      content:
                          'Viết rõ:\n'
                          '• Thành phần chính\n'
                          '• Cách ăn ngon nhất\n'
                          '• Lưu ý dị ứng (hải sản, đậu phộng...)\n'
                          '• Mức độ cay, ngọt, khẩu phần',
                    ),

                    const SizedBox(height: 48),

                    // Lưu ý quan trọng
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                'Lưu ý quan trọng',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '• Các trường có dấu * là bắt buộc\n'
                            '• Phải chọn ảnh và danh mục trước khi thêm\n'
                            '• Sau khi thêm thành công, món ăn sẽ xuất hiện ngay trong danh sách',
                            style: TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Nút đóng
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: Colors.redAccent.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tôi đã hiểu',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 28),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: const TextStyle(
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}