import 'package:flutter/material.dart';
import 'package:frontend/features/user/profile/profile.dart';
import 'package:frontend/features/user/order/history_order.dart';
import './widgets/section.dart';
import './widgets/setting_title.dart';
import './widgets/switch_title.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: width >= 900 ? 700 : width,
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Section(title: 'Tài khoản'),
                  SettingTile(
                    icon: Icons.person,
                    title: 'Thông tin cá nhân',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  SettingTile(
                    icon: Icons.location_on,
                    title: 'Địa chỉ giao hàng',
                  ),
                  SettingTile(
                    icon: Icons.lock,
                    title: 'Đổi mật khẩu',
                  ),

                  SizedBox(height: 24),

                  Section(title: 'Ứng dụng'),
                  SwitchTile(
                    icon: Icons.notifications,
                    title: 'Thông báo',
                  ),
                  SwitchTile(
                    icon: Icons.dark_mode,
                    title: 'Chế độ tối',
                  ),
                  SettingTile(
                    icon: Icons.language,
                    title: 'Ngôn ngữ',
                    trailing: Text('Tiếng Việt'),
                  ),

                  SizedBox(height: 24),

                  Section(title: 'Khác'),
                  SettingTile(
                    icon: Icons.history,
                    title: 'Lịch sử đơn hàng',
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryOrderScreen(),
                        ),
                      );
                    },
                  ),
                  SettingTile(
                    icon: Icons.support_agent,
                    title: 'Hỗ trợ',
                  ),
                  SettingTile(
                    icon: Icons.description,
                    title: 'Điều khoản & chính sách',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
