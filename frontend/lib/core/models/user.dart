import '../enum/user_role.dart';

class User {
  final int? id;
  final String username;
  final String email;
  final String phoneNumber;
  final String defaultAddress;
  final UserRole? role;
  final String? passwordHash;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.defaultAddress,
    this.role,
    this.passwordHash,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phonenumber'],
      defaultAddress: json['default_address'],
      role: UserRole.fromString(json['role']),
      passwordHash: json['password_hash'] ?? ''
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      phoneNumber: map['phonenumber'],
      defaultAddress: map['default_address'],
      role:UserRole.fromString(map['role']),
      passwordHash: map['password_hash']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phonenumber': phoneNumber,
      'default_address': defaultAddress,
      'role': role!.value,
      'password_hash': passwordHash
    };
  }
}