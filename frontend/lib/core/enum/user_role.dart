enum UserRole {
  admin('admin'),
  user('user'),
  restaurantOwner('restaurant owner'),
  shipper('shipper'),
  support('support');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.value == role,
      orElse: () => UserRole.user,
    );
  }
}