class CategoryFood {
  final int id;
  final String name;

  CategoryFood({required this.id, required this.name});

  factory CategoryFood.fromJson(Map<String, dynamic> json) {
    return CategoryFood(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

  