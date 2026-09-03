import 'package:postgres/postgres.dart';
class RestaurantModel {
  final int id;
  final int owner;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isOpen;
  final double ratingAvg;
  final DateTime createdAt;

  RestaurantModel({
    required this.id,
    required this.owner,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    required this.isOpen,
    required this.ratingAvg,
    required this.createdAt,
  });

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
  // ================= FROM JSON =================
  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map['id'],
      owner: map['owner'],
      name: map['name'],
      address: map['address'],

      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),

      isOpen: map['is_open'] ?? true,

      ratingAvg: _toDouble(map['rating_avg']) ?? 0.0,

      createdAt: map['created_at'] is DateTime
          ? map['created_at']
          : DateTime.parse(map['created_at'].toString()),
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_open': isOpen,
      'rating_avg': ratingAvg,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RestaurantModel.fromRow(ResultRow row) {
    final data = row.toColumnMap(); // chuyển sang map theo tên cột
    return RestaurantModel.fromMap(data);
  }
}