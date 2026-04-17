import 'package:flutter/material.dart';
import 'notification_type.dart';

class NotificationUIHelper {
  static IconData getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newOrder:
        return Icons.shopping_cart;
      case NotificationType.orderCancelled:
        return Icons.cancel;
      case NotificationType.orderConfirmed:
        return Icons.check_circle;
      case NotificationType.orderDelivering:
        return Icons.local_shipping;
      case NotificationType.orderDelivered:
        return Icons.done_all;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.promotion:
        return Icons.local_offer;
    }
  }

  static Color getColor(NotificationType type) {
    switch (type) {
      case NotificationType.newOrder:
        return Colors.blue;
      case NotificationType.orderCancelled:
        return Colors.red;
      case NotificationType.orderConfirmed:
        return Colors.green;
      case NotificationType.orderDelivering:
        return Colors.orange;
      case NotificationType.orderDelivered:
        return Colors.teal;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.promotion:
        return Colors.purple;
    }
  }
}