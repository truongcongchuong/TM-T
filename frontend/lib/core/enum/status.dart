enum UserStatusEnum {
  active('hoạt động'),
  inactive('không hoạt động'),
  locked('bị khóa');

  final String value;
  const UserStatusEnum(this.value);

  static UserStatusEnum fromString(String status) {
    return UserStatusEnum.values.firstWhere(
      (e) => e.value == status,
      orElse: () => UserStatusEnum.active,
    );
  }
}

enum StatusDomainEnum {
  user('user'),
  restaurant('restaurant'),
  payment('payment'),
  food('food'),
  order('order');

  final String value;
  const StatusDomainEnum(this.value);
  static StatusDomainEnum fromString(String domain) {
    return StatusDomainEnum.values.firstWhere(
      (e) => e.value == domain,
      orElse: () => StatusDomainEnum.user,
    );
  }
}

enum OrderStatusEnum {
  pending('chờ xử lý'),
  confirmed('đã xác nhận'),
  delivering('đang giao hàng'),
  completed('hoàn thành'),
  cancelled('đã hủy');

  final String value;
  const OrderStatusEnum(this.value);

  static OrderStatusEnum fromString(String status) {
    return OrderStatusEnum.values.firstWhere(
      (e) => e.value == status,
      orElse: () => OrderStatusEnum.pending,
    );
  }
}

enum PaymentStatusEnum {
  unpaid('chưa thanh toán'),
  paid('đã thanh toán');

  final String value;
  const PaymentStatusEnum(this.value);

  static PaymentStatusEnum fromString(String status) {
    return PaymentStatusEnum.values.firstWhere(
      (e) => e.value == status,
      orElse: () => PaymentStatusEnum.unpaid,
    );
  }
}