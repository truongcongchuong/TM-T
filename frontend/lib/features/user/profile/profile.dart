import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/models/user.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/auth/screens/login.dart';
import 'package:frontend/features/user/services/profile_services.dart';

import './widgets/edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hồ sơ'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        body: const Center(
          child: Text('Không tìm thấy thông tin người dùng'),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 900 : 600,
            ),
            child: Column(
              children: [
                _buildHeaderCard(user),
                const SizedBox(height: 20),
                _buildMainContent(context, user, authProvider, isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeaderCard(User user) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.08),
              ),
              child: const Icon(
                Icons.person,
                size: 56,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: 18,
                        color: user.role == 'admin'
                            ? Colors.red
                            : Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.role == 'admin'
                            ? 'Quản trị viên'
                            : 'Người dùng',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: user.role == 'admin'
                              ? Colors.red
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MAIN CONTENT =================

  Widget _buildMainContent(
    BuildContext context,
    User user,
    AuthProvider authProvider,
    bool isDesktop,
  ) {
    return Flex(
      direction: isDesktop ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildInfoCard(user),
        ),
        SizedBox(
          width: isDesktop ? 16 : 0,
          height: isDesktop ? 0 : 16,
        ),
        Expanded(
          flex: 2,
          child: _buildActionCard(context, user, authProvider),
        ),
      ],
    );
  }

  // ================= INFO CARD =================

  Widget _buildInfoCard(User user) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cá nhân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
            ),
            const Divider(height: 28),
            _buildInfoRow(
              icon: Icons.phone,
              label: 'Số điện thoại',
              value: user.phoneNumber,
            ),
            const Divider(height: 28),
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Địa chỉ nhận hàng',
              value: user.defaultAddress,
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACTION CARD =================

  Widget _buildActionCard(
    BuildContext context,
    User user,
    AuthProvider authProvider,
  ) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tài khoản',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditProfileButton(context, user, authProvider),
            const SizedBox(height: 12),
            _buildLogoutButton(context, authProvider),
          ],
        ),
      ),
    );
  }

  // ================= BUTTONS =================

  Widget _buildEditProfileButton(
    BuildContext context,
    User user,
    AuthProvider authProvider,
  ) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfileScreen(user: user),
            ),
          );

          if (result == null || !context.mounted) return;

          final token = authProvider.token;
          if (token == null) return;

          final profileService = ProfileService();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          final updatedUser = User(
            id: user.id,
            username: result['username'],
            email: result['email'],
            phoneNumber: result['phoneNumber'],
            defaultAddress: result['defaultAddress'],
            role: user.role,
            passwordHash: user.passwordHash,
          );

          final (success, message) =
              await profileService.updateProfile(updatedUser, token);

          if (context.mounted) Navigator.pop(context);

          if (!context.mounted) return;

          if (success) {
            await authProvider.saveSession(updatedUser, token);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Đăng xuất',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
      ),
    );
  }

  // ================= INFO ROW =================

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
