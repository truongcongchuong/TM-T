class Food {
  final int? id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final double? ratingAvg;
  final bool? isAvailable;
  final int? categoryId;
  final int restaurantId;

  Food({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    this.ratingAvg,
    this.isAvailable,
    this.categoryId,
    required this.restaurantId,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      price: json['price'],
      description: json['description'],
      ratingAvg: json['rating_avg'] != null ? (json['rating_avg'] as num).toDouble() : null,
      isAvailable: json['is_available'],
      categoryId: json['category_id'],
      restaurantId: json['restaurant_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_url': imageUrl,
    'price': price,
    'description': description,
    'rating_avg': ratingAvg,
    'is_available': isAvailable,
    'category_id': categoryId,
    'restaurant_id': restaurantId,
  };

  Food copyWith({
    int? id,
    String? name,
    String? imageUrl,
    double? price,
    String? description,
    double? ratingAvg,
    bool? isAvailable,
    int? categoryId,
    int? restaurantId,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      description: description ?? this.description,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      isAvailable: isAvailable ?? this.isAvailable,
      categoryId: categoryId ?? this.categoryId,
      restaurantId: restaurantId ?? this.restaurantId, // restaurantId không đổi khi cập nhật thông tin món ăn
    );
  }
}
