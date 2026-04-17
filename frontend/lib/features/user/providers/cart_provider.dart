import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/models/food.dart';
import "package:frontend/core/models/cart.dart";
import 'package:frontend/features/user/services/cart_service.dart';


class CartProvider extends ChangeNotifier {
  CartService cartService = CartService();
  String _cartKey(int userID) => 'cart_user_$userID';

  Cart _cart = Cart(userId: -1, items: []);

  Cart get cart => _cart;
  List<ItemCart> get items => _cart.items;
  double get totalPrice => _cart.totalPrice;
  bool get isEmpty => items.isEmpty;

  // ================= LOAD =================
  Future<void> loadLocalCart(int userID) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cartKey(userID));

    if (jsonString == null) {
      _cart = Cart(userId: userID, items: []);
      notifyListeners();
      return;
    }

    _cart = Cart.fromJson(jsonDecode(jsonString));
    notifyListeners();
  }

    Future<void> initCart(String token) async {
    // 1. Load local
    await loadLocalCart(_cart.userId);
    notifyListeners();

    // 2. Sync server
    try {
      final response = await cartService.loadCart(token, _cart.userId);
      await saveCart(response);
      notifyListeners();
    } catch (_) {}
  }

  // update cart local sau khi có dữ liệu mới từ server
  Future<void> saveCart(Cart newCart) async {
    _cart = newCart;
    await _saveCart();
  }

  // ================= SAVE =================
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cartKey(_cart.userId),
      jsonEncode(_cart.toJson()),
    );
  }

  // ================= ACTION =================
  Future<bool> addFood(Food food, int quantity, String token) async {

    // lưu vào local
    final index = items.indexWhere((e) => e.food.id == food.id);

    if (index >= 0) {
      items[index].quantity += quantity;
    } else {
      items.add(ItemCart(food: food, quantity: quantity));
    }

    await _saveCart();
    notifyListeners();

    // lưu vào server
    final updatedItem = index >= 0
    ? items[index]
    : items.last;

    final result = await cartService.addToCart(token, updatedItem);
    if (!result) {
      // nếu lưu server thất bại thì rollback lại local
      if (index >= 0) {
        items[index].quantity -= quantity;
      } else {
        items.removeLast();
      }
      await _saveCart();
      notifyListeners();

      return false;
    }

    return true;
  }

  Future<void> removeFood(int foodId) async {
    items.removeWhere((e) => e.food.id == foodId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> decrease(int foodId) async {
    final index = items.indexWhere((e) => e.food.id == foodId);
    if (index < 0) return;

    if (items[index].quantity > 1) {
      items[index].quantity--;
    } else {
      items.removeAt(index);
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> clear() async {
    items.clear();
    await _saveCart();
    notifyListeners();
  }
}
