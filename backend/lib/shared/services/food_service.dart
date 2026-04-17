import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import 'package:backend/shared/models/food_model.dart';
import 'package:backend/shared/models/category_food_model.dart';

class FoodService {

  Future<List<FoodModel>> getAllFoods() async {
    final Connection conn = await DatabaseConfig.connection();
    final result = await conn.execute('SELECT * FROM foods');
    return result.map((row) => FoodModel.fromRow(row)).toList();
  }

  Future<List<FoodModel>> filterFood(String query) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named("SELECT * FROM foods WHERE name ILIKE @key OR ILIKE @key" ),
      parameters: {"key": "%$query%"}
    );

    return result.map((row) => FoodModel.fromRow(row)).toList();
  }

  Future<int> addFood(FoodModel food) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      final result = await conn.execute(
        Sql.named('''
          INSERT INTO foods (name, description, price, image_url)
          VALUES (@name, @description, @price, @image_url)
          RETURNING id;
        '''),
        parameters: {
          "name": food.name,
          "description": food.description,
          "price": food.price,
          "image_url": food.imageUrl,
        },
      );
      return result.first[0] as int;
    } catch (e) {
      print('Error adding food: $e');
      return -1;
    } finally {
    }
  }

  Future<bool> deleteFood(int id) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      await conn.execute(
        Sql.named('DELETE FROM foods WHERE id = @id'),
        parameters: {"id": id},
      );
      return true;
    } catch (e) {
      print('Error deleting food: $e');
      return false;
    } finally {
    }
  }

  Future<bool> updateFood(FoodModel food) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      await conn.execute(
        Sql.named('''
          UPDATE foods
          SET name = @name,
              description = @description,
              price = @price,
              image_url = @image_url
          WHERE id = @id
        '''),
        parameters: {
          "id": food.id,
          "name": food.name,
          "description": food.description,
          "price": food.price,
          "image_url": food.imageUrl,
        },
      );
      return true;
    } catch (e) {
      print('Error updating food: $e');
      return false;
    } finally {
    }
  }

  Future<FoodModel?> getFoodById(int id) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      final result = await conn.execute(
        Sql.named('SELECT * FROM foods WHERE id = @id'),
        parameters: {"id": id},
      );

      if (result.isEmpty) return null;
      return FoodModel.fromRow(result.first);
    } catch (e) {
      print('Error fetching food by id: $e');
      return null;
    } finally {
    }
  }

  // lấy category food
  Future<List<CategoryFood?>> getAllCategories() async {
    try {
      final Connection conn = await DatabaseConfig.connection();
      final result = await conn.execute('SELECT * FROM category');
      return result.map((row) => CategoryFood.fromRow(row)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    } 
  }

  // lấy food by category
  Future<List<FoodModel>> getFoodsByCategory(int categoryId) async {
    try {
      final Connection conn = await DatabaseConfig.connection();

      if (categoryId == 0) {
        // LẤY TẤT CẢ
        final result = await conn.execute(
          Sql.named('SELECT * FROM foods WHERE is_available = true'),
        );
        return result.map((row) => FoodModel.fromRow(row)).toList();
      }

      // LỌC THEO CATEGORY
      final result = await conn.execute(
        Sql.named('SELECT * FROM foods WHERE category_id = @categoryId AND is_available = true'),
        parameters: {"categoryId": categoryId},
      );

      return result.map((row) => FoodModel.fromRow(row)).toList();
    } catch (e) {
      print('Error fetching foods by category: $e');
      return [];
    }
  }

  Future<List<FoodModel>> searchFood(String query) async {
    final conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named('''
        SELECT 
          *,
          CASE
            WHEN name ILIKE @query THEN 3
            WHEN description ILIKE  @query THEN 2
            ELSE 1
          END AS score
        FROM foods
        WHERE name ILIKE @query
          OR description ILIKE  @query
        ORDER BY score DESC, rating_avg DESC
        LIMIT 20
      '''),
      parameters: {'query': '%$query%'},
    );

    return result.map((row) => FoodModel.fromRow(row)).toList();
  }
}