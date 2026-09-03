import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import 'package:backend/shared/models/food_model.dart';
import 'package:backend/shared/models/category_food_model.dart';
import 'package:backend/shared/models/food_response.dart';

class FoodService {

  Future<List<FoodResponse>> getAllFoods() async {
    final Connection conn = await DatabaseConfig.connection();
    final result = await conn.execute(
      Sql.named(
      '''
      SELECT 
        -- FOOD
        f.id AS food_id,
        f.name AS food_name,
        f.price,
        f.description,
        f.image_url,
        f.rating_avg AS food_rating_avg,
        f.is_available,
        f.category_id,
        f.restaurant_id,
        f.preparation_time,

        -- RESTAURANT
        r.id AS restaurant_id,
        r.name AS restaurant_name,
        r.owner,
        r.address,
        r.latitude,
        r.longitude,
        r.is_open,
        r.rating_avg AS restaurant_rating_avg,
        r.created_at

      FROM foods f
      JOIN restaurants r ON f.restaurant_id = r.id
      WHERE r.is_open = true AND f.is_available = true;
      '''),
    );
    return result.map((row) => FoodResponse.fromRow(row)).toList();
  }

  Future<List<FoodResponse>> filterFood(String query) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        SELECT
          -- FOOD
          f.id AS food_id,
          f.name AS food_name,
          f.price,
          f.description,
          f.image_url,
          f.rating_avg AS food_rating_avg,
          f.is_available,
          f.category_id,
          f.restaurant_id,
          f.preparation_time,

          -- RESTAURANT
          r.id AS restaurant_id,
          r.name AS restaurant_name,
          r.owner,
          r.address,
          r.latitude,
          r.longitude,
          r.is_open,
          r.rating_avg AS restaurant_rating_avg,
          r.created_at

        FROM foods f
        JOIN restaurants r ON f.restaurant_id = r.id 
        WHERE f.name ILIKE @key OR ILIKE @key
      '''),
      parameters: {"key": "%$query%"}
    );

    return result.map((row) => FoodResponse.fromRow(row)).toList();
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

  Future<FoodResponse?> getFoodById(int id) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      final result = await conn.execute(
        Sql.named(
          '''
            SELECT 
                -- FOOD
              f.id AS food_id,
              f.name AS food_name,
              f.price,
              f.description,
              f.image_url,
              f.rating_avg AS food_rating_avg,
              f.is_available,
              f.category_id,
              f.restaurant_id,
              f.preparation_time,

              -- RESTAURANT
              r.id AS restaurant_id,
              r.name AS restaurant_name,
              r.owner,
              r.address,
              r.latitude,
              r.longitude,
              r.is_open,
              r.rating_avg AS restaurant_rating_avg,
              r.created_at

            FROM foods f
            JOIN restaurants r ON f.restaurant_id = r.id 
            WHERE f.id = @id
          '''),
        parameters: {"id": id},
      );

      if (result.isEmpty) return null;
      return FoodResponse.fromRow(result.first);
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
  Future<List<FoodResponse>> getFoodsByCategory(int categoryId) async {
    try {
      final Connection conn = await DatabaseConfig.connection();

      if (categoryId == 0) {
        // LẤY TẤT CẢ
        final result = await conn.execute(
          Sql.named(
            '''
              SELECT
                -- FOOD
              f.id AS food_id,
              f.name AS food_name,
              f.price,
              f.description,
              f.image_url,
              f.rating_avg AS food_rating_avg,
              f.is_available,
              f.category_id,
              f.restaurant_id,
              f.preparation_time,

              -- RESTAURANT
              r.id AS restaurant_id,
              r.name AS restaurant_name,
              r.owner,
              r.address,
              r.latitude,
              r.longitude,
              r.is_open,
              r.rating_avg AS restaurant_rating_avg,
              r.created_at

            FROM foods f
            JOIN restaurants r ON f.restaurant_id = r.id 
            WHERE f.is_available = true
            '''),
        );
        return result.map((row) => FoodResponse.fromRow(row)).toList();
      }

      // LỌC THEO CATEGORY
      final result = await conn.execute(
        Sql.named('''
          SELECT 
          -- FOOD
            f.id AS food_id,
            f.name AS food_name,
            f.price,
            f.description,
            f.image_url,
            f.rating_avg AS food_rating_avg,
            f.is_available,
            f.category_id,
            f.restaurant_id,
            f.preparation_time,

            -- RESTAURANT
            r.id AS restaurant_id,
            r.name AS restaurant_name,
            r.owner,
            r.address,
            r.latitude,
            r.longitude,
            r.is_open,
            r.rating_avg AS restaurant_rating_avg,
            r.created_at

          FROM foods f
          JOIN restaurants r ON f.restaurant_id = r.id  
          WHERE f.category_id = @categoryId AND f.is_available = true
        '''),
        parameters: {"categoryId": categoryId},
      );

      return result.map((row) => FoodResponse.fromRow(row)).toList();
    } catch (e) {
      print('Error fetching foods by category: $e');
      return [];
    }
  }

  Future<List<FoodResponse>> searchFood(String query) async {
    final conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named('''
        SELECT 
          -- FOOD
          f.id AS food_id,
          f.name AS food_name,
          f.price,
          f.description,
          f.image_url,
          f.rating_avg AS food_rating_avg,
          f.is_available,
          f.category_id,
          f.restaurant_id,
          f.preparation_time,

          -- RESTAURANT
          r.id AS restaurant_id,
          r.name AS restaurant_name,
          r.owner,
          r.address,
          r.latitude,
          r.longitude,
          r.is_open,
          r.rating_avg AS restaurant_rating_avg,
          r.created_at,

          -- SCORE (search ranking)
          CASE
            WHEN f.name ILIKE @query THEN 3
            WHEN f.description ILIKE @query THEN 2
            ELSE 1
          END AS score

        FROM foods f
        JOIN restaurants r ON f.restaurant_id = r.id

        WHERE (f.name ILIKE @query OR f.description ILIKE @query)
          AND f.is_available = true
          AND r.is_open = true

        ORDER BY score DESC, f.rating_avg DESC
        LIMIT 20
      '''),
      parameters: {'query': '%$query%'},
    );

    return result.map((row) => FoodResponse.fromRow(row)).toList();
  }
}