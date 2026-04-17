import 'package:frontend/core/models/food.dart';

class ItemCart {
  final Food food;
  int quantity;

  ItemCart({
    required this.food,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'food': food.toJson(),
        'quantity': quantity,
      };

  factory ItemCart.fromJson(Map<String, dynamic> json) {
    return ItemCart(
      food: Food.fromJson(json['food']),
      quantity: json['quantity'],
    );
  }
}

class Cart {
  final int userId;
  final List<ItemCart> items;

  Cart({
    required this.userId,
    required this.items,
  });

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.food.price * item.quantity);

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['user_id'] as int,
      items: (json['items'] as List)
          .map((e) => ItemCart.fromJson(e))
          .toList(),
    );
  }
}
