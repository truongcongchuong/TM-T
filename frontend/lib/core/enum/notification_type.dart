enum NotificationType {
  newOrder,
  orderCancelled,
  orderConfirmed,
  orderDelivering,
  orderDelivered,
  system,
  promotion,
}

extension NotificationTypeExtension on NotificationType {
  String get code {
    switch (this) {
      case NotificationType.newOrder:
        return "NEW_ORDER";
      case NotificationType.orderCancelled:
        return "ORDER_CANCELLED";
      case NotificationType.orderConfirmed:
        return "ORDER_CONFIRMED";
      case NotificationType.orderDelivering:
        return "ORDER_DELIVERING";
      case NotificationType.orderDelivered:
        return "ORDER_DELIVERED";
      case NotificationType.system:
        return "SYSTEM";
      case NotificationType.promotion:
        return "PROMOTION";
    }
  }

  static NotificationType fromCode(String code) {
    switch (code) {
      case "NEW_ORDER":
        return NotificationType.newOrder;
      case "ORDER_CANCELLED":
        return NotificationType.orderCancelled;
      case "ORDER_CONFIRMED":
        return NotificationType.orderConfirmed;
      case "ORDER_DELIVERING":
        return NotificationType.orderDelivering;
      case "ORDER_DELIVERED":
        return NotificationType.orderDelivered;
      case "SYSTEM":
        return NotificationType.system;
      case "PROMOTION":
        return NotificationType.promotion;
      default:
        throw Exception("Unknown notification type: $code");
    }
  }
}