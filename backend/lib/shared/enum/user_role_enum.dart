enum UserRoleEnum {
  admin('admin'),
  user('user'),
  restaurantOwner('restaurant owner'),
  shipper('shipper'),
  support('support');

  final String value;
  const UserRoleEnum(this.value);

  static UserRoleEnum fromString(String role) {
    return UserRoleEnum.values.firstWhere(
      (e) => e.value == role,
      orElse: () => UserRoleEnum.user,
    );
  }
}