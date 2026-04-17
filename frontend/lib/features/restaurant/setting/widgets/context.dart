import 'package:flutter/material.dart';
import 'build_section.dart';
import 'setting_field.dart';
import 'setting_switch.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/auth/screens/login.dart';
import 'package:provider/provider.dart';

class Context extends StatelessWidget {
  const Context({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text(
              'Cài đặt hệ thống',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            BuildSection(
              title: 'Thông tin cửa hàng',
              children: const [
                SettingField(label: 'Tên cửa hàng'),
                SettingField(label: 'Email liên hệ'),
                SettingField(label: 'Số điện thoại'),
              ],
            ),

            const SizedBox(height: 24),

            BuildSection(
              title: 'Cấu hình hệ thống',
              children: const [
                SettingSwitch(label: 'Cho phép đặt hàng'),
                SettingSwitch(label: 'Hiển thị đánh giá món ăn'),
                SettingSwitch(label: 'Bảo trì hệ thống'),
              ],
            ),

            const SizedBox(height: 24),

            BuildSection(
              title: 'Bảo mật',
              children: const [
                SettingSwitch(label: 'Xác thực 2 bước'),
                SettingSwitch(label: 'Ghi log đăng nhập'),
              ],
            ),

            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Xác nhận đăng xuất'),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );

                if (confirm != true || !context.mounted) return;

                await authProvider.deleteSession();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đăng xuất thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
                icon: const Icon(Icons.logout, color: Colors.white,),
                label: const Text(
                  'Đăng xuất', 
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}