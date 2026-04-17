import 'package:flutter/material.dart';
import 'package:frontend/core/models/nontification.dart';
import './widgets/notification_item.dart';
import './widgets/notification_detail_screen.dart';
import 'package:frontend/features/user/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/auth/screens/login.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = false;
  bool _hasLoaded = false;

  final NotificationService notificationService = NotificationService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = context.watch<AuthProvider>();

    if (auth.isLoggedIn && !_hasLoaded) {
      _hasLoaded = true;
      _loadNotifications(auth.token!);
    }
  }

  Future<void> _loadNotifications(String token) async {
    setState(() => isLoading = true);

    final notifiLoad = await notificationService.loadNotification(token);

    if (!mounted) return;

    setState(() {
      notifications = notifiLoad;
      isLoading = false;
    });
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index] =
          notifications[index].copyWith(isRead: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 60),
            const SizedBox(height: 16),
            const Text("Bạn cần đăng nhập để xem thông báo"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: const Text("Đăng nhập"),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Thông báo")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("Không có thông báo"))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return NotificationItem(
                      notification: notifications[index],
                      onTap: () {
                        _markAsRead(index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationDetailScreen(
                              notification: notifications[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}