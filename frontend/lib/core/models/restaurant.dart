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

  // ================= FROM JSON =================
  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map['id'],
      owner: map['owner'],
      name: map['name'],
      address: map['address'],
      latitude: map['latitude'] != null
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
      isOpen: map['is_open'] ?? true,
      ratingAvg: map['rating_avg'] != null
          ? (map['rating_avg'] as num).toDouble()
          : 0.0,
      createdAt: map['created_at'] is DateTime
          ? map['created_at']
          : DateTime.parse(map['created_at'])
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

  RestaurantModel copyWith({
    int? id,
    int? owner,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    bool? isOpen,
    double? ratingAvg,
    DateTime? createdAt,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOpen: isOpen ?? this.isOpen,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}