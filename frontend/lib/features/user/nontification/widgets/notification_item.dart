import 'package:flutter/material.dart';
import 'package:frontend/core/models/nontification.dart';
import 'package:frontend/core/enum/icon_color.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          NotificationUIHelper.getIcon(notification.type),
          color: NotificationUIHelper.getColor(notification.type),
        ),
        title: Text(
          notification.title ?? "",
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(notification.body ?? ""),
        trailing: notification.isRead
            ? null
            : const Icon(Icons.circle, size: 10, color: Colors.red),
      ),
    );
  }
}