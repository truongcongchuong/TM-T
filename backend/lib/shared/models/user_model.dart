import 'package:postgres/postgres.dart';
class User {
  int? id;
  final String username;
  final String email;
  final String? passwordHash;
  final String role;
  final String? defaultAddress;
  final String phoneNumber;
  final DateTime? createdAt;
  final String status;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.passwordHash,
    String? role,
    this.defaultAddress,
    this.createdAt,
    this.status = 'active',
  }) : role = role ?? 'user';

  // Lấy từ DB → Model
  factory User.fromRow(ResultRow row) {
    Map<String, Object?> data = row.toColumnMap();
    return User(
      id: data['id'] as int,
      username: data['username'] as String,
      email: data['email'] as String,
      passwordHash: data['password_hash'] as String,
      role: data['role'] as String?,
      defaultAddress: data['default_address'] as String?,
      phoneNumber: data['phonenumber'] as String,
      createdAt: data['created_at'] as DateTime?,
      status: data['status'] as String? ?? 'active',
    );
  }

  // Trả ra JSON → client (Flutter)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "password_hash": passwordHash,
      "role": role,
      "default_address": defaultAddress,
      "phonenumber": phoneNumber,
      "created_at": createdAt?.toString(),
      "status": status,
    };
  }

  // Tạo từ JSON 
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] ?? "",
      role: map['role'] as String?,
      defaultAddress: map['default_address'] as String?,
      phoneNumber: map['phonenumber'] as String,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      status: map['status'] as String? ?? 'active',
    );
  }
}
