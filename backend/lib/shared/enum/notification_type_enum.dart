enum NotificationTypeEnum {
  newOrder,
  orderCancelled,
  orderConfirmed,
  orderDelivering,
  orderDelivered,
  system,
  promotion,
}

extension NotificationTypeExtension on NotificationTypeEnum {

  String get code {
    switch (this) {
      case NotificationTypeEnum.newOrder:
        return "NEW_ORDER";
      case NotificationTypeEnum.orderCancelled:
        return "ORDER_CANCELLED";
      case NotificationTypeEnum.orderConfirmed:
        return "ORDER_CONFIRMED";
      case NotificationTypeEnum.orderDelivering:
        return "ORDER_DELIVERING";
      case NotificationTypeEnum.orderDelivered:
        return "ORDER_DELIVERED";
      case NotificationTypeEnum.system:
        return "SYSTEM";
      case NotificationTypeEnum.promotion:
        return "PROMOTION";
    }
  }

  static NotificationTypeEnum fromCode(String code) {
    switch (code) {
      case "NEW_ORDER":
        return NotificationTypeEnum.newOrder;
      case "ORDER_CANCELLED":
        return NotificationTypeEnum.orderCancelled;
      case "ORDER_CONFIRMED":
        return NotificationTypeEnum.orderConfirmed;
      case "ORDER_DELIVERING":
        return NotificationTypeEnum.orderDelivering;
      case "ORDER_DELIVERED":
        return NotificationTypeEnum.orderDelivered;
      case "SYSTEM":
        return NotificationTypeEnum.system;
      case "PROMOTION":
        return NotificationTypeEnum.promotion;
      default:
        throw Exception("Unknown notification type: $code");
    }
  }
}