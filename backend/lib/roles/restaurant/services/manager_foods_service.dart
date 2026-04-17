import 'package:backend/shared/models/food_model.dart';
import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import '../../../shared/services/upload_file_service.dart';
import '../../../core/config/config.dart';

class ManagerFoodsService {

  final UploadFileService uploadFileService = UploadFileService();

  Future<List<FoodModel>> getFoodsForManager(String restaurantId) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        SELECT *
        FROM foods 
        WHERE restaurant_id = @restaurantId;
        '''
      ),
      parameters: {
        'restaurantId': restaurantId,
      },
    );


    return result.map((row) => FoodModel.fromRow(row)).toList();
  }

  Future<FoodModel?> editFood(FoodModel food, String? newImageUrl) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        UPDATE foods
        SET name = @name,
            description = @description,
            price = @price,
            image_url = COALESCE(@newImageUrl, @imageUrl),
            is_available = @isAvailable,
            category_id = @categoryId
        WHERE id = @id AND restaurant_id = @restaurantId
        RETURNING *;
        '''
      ),
      parameters: {
        'id': food.id,
        'restaurantId': food.restaurantId, 
        'name': food.name,
        'description': food.description,
        'price': food.price,
        'imageUrl': food.imageUrl,
        'isAvailable': food.isAvailable,
        'categoryId': food.categoryId,
        'newImageUrl': newImageUrl,
      },
    );

    if (result.isEmpty) {
      if (newImageUrl != null) {
        await uploadFileService.deleteFile(newImageUrl, uploadDirectory);
      }
      return null; // Không tìm thấy món ăn để cập nhật
    }

    if (newImageUrl != null && food.imageUrl != newImageUrl) {
      await uploadFileService.deleteFile(food.imageUrl, uploadDirectory);
    }
    return FoodModel.fromRow(result.first);
  }

  Future<bool> deleteFood(int restaurantId, int? foodId) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        DELETE FROM foods
        WHERE id = @foodId AND restaurant_id = @restaurantId
        RETURNING image_url;
        '''
      ),
      parameters: {
        'foodId': foodId,
        'restaurantId': restaurantId,
       },
     );

    if (result.isEmpty) {
      return false; // Không tìm thấy món ăn để xóa
    }

    final String imageUrl = result.first.toColumnMap()['image_url'] as String;
    await uploadFileService.deleteFile(imageUrl, uploadDirectory);
    return true;
  }

  Future<FoodModel?> addFood(FoodModel food) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        INSERT INTO foods (name, description, price, image_url, is_available, category_id, restaurant_id)
        VALUES (@name, @description, @price, @imageUrl, @isAvailable, @categoryId, @restaurantId)
        RETURNING *;
        '''
      ),
      parameters: {
        'name': food.name,
        'description': food.description,
        'price': food.price,
        'imageUrl': food.imageUrl,
        'isAvailable': food.isAvailable ?? true,
        'categoryId': food.categoryId,
        'restaurantId': food.restaurantId,
      },
    );

    return FoodModel.fromRow(result.first);
  }
}