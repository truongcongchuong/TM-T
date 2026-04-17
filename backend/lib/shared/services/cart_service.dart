import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import 'package:backend/shared/models/cart_model.dart';
import 'package:backend/shared/models/food_model.dart';

class CartService {
  // lấy cart
 Future<Map<String, dynamic>> getCartByUser(int userId) async {
    final Connection conn = await DatabaseConfig.connection();
    final result = await conn.execute(
      Sql.named('''
        SELECT 
          c.user_id,
          c.quantity,
          f.id,
          f.name,
          f.price,
          f.image_url,
          f.restaurant_id,
          f.category_id,
          f.description,
          f.rating_avg,
          f.is_available
        FROM carts c
        JOIN foods f ON c.food_id = f.id
        WHERE c.user_id = @userId;
      '''),
      parameters: {'userId': userId},
    );

    final items = result.map((row) {
      final data = row.toColumnMap();
      return {
        "food": FoodModel.fromMap(data).toMap(),
        "quantity": data["quantity"],
      };
    }).toList();

    return {
      "user_id": userId,
      "items": items,
    };
  }

  // thêm món vào giỏ hàng
  Future<bool> addItemToCart(CartModel cart) async {
    try {
      final Connection conn = await DatabaseConfig.connection();

      await conn.execute(
        Sql.named('''
          INSERT INTO carts (user_id, food_id, quantity)
          VALUES (@userId, @foodId, @quantity)
          ON CONFLICT (user_id, food_id)
          DO UPDATE SET quantity = carts.quantity + @quantity;
        '''),
        parameters: {
          'userId': cart.userId,
          'foodId': cart.foodId,
          'quantity': cart.quantity,
        },
      );

      return true;
    } catch (e) {
      print('Error adding item to cart: $e');
      return false;
    }
  }

  // cập nhật số lượng món trong giỏ hàng
  Future<void> updateCartItem(CartModel cart) async {
    final Connection conn = await DatabaseConfig.connection();

    await conn.execute(
      Sql.named('''
        UPDATE carts
        SET quantity = @quantity
        WHERE user_id = @userId AND food_id = @foodId;
      '''),
      parameters: {
        'userId': cart.userId,
        'foodId': cart.foodId,
        'quantity': cart.quantity,
      },
    );
  }

  // xóa món khỏi giỏ hàng
  Future<bool> removeItemFromCart(int userId, int foodId) async {
    try {
      final Connection conn = await DatabaseConfig.connection();
      await conn.execute(
        Sql.named('''
          DELETE FROM carts
          WHERE user_id = @userId AND food_id = @foodId;
        '''),
        parameters: {
          'userId': userId,
          'foodId': foodId,
        },
      );
    return true;
    } catch (e) {

      print("erro: $e");
      return false;
    }
  }

  // =========================== delete cart ========================

  // // update cart
  // Future<void> updateCart(List<CartModel> cart) async {
  //   final conn = await DatabaseConfig.connect();

  //   // Xóa tất cả món cũ trong giỏ hàng

  //   int userId = cart.first.userId; // lấy userId từ món đầu tiên (giả sử tất cả món đều cùng userId)
  //   await conn.execute(
  //     Sql.named('''
  //       DELETE FROM carts
  //       WHERE user_id = @userId;
  //     '''),
  //     parameters: {'userId': userId},
  //   );

  //   // Thêm lại tất cả món mới vào giỏ hàng
  //   cart.map((item) => {
  //     conn.execute(
  //       Sql.named('''
  //         INSERT INTO carts (user_id, food_id, quantity)
  //         VALUES (@userId, @foodId, @quantity);
  //       '''),
  //       parameters: {
  //         'userId': item.userId,
  //         'foodId': item.foodId,
  //         'quantity': item.quantity,
  //       },
  //     ),
  //   });
  // }
}