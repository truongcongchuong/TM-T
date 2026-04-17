import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import 'package:backend/shared/models/category_food_model.dart';
import 'package:backend/shared/models/info_public_user_model.dart';
class PublicService {
  Future<String?> getNameCategoryById(int id) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      final result = await conn.execute(
        Sql.named('''
            SELECT name FROM category WHERE id = @id
        '''),
        parameters: {'id': id},
      );

      if (result.isEmpty) return null;
      
      return result.first[0] as String;
    } catch (e) {
      print("lỗ phần lấy tên thể loại đồ ăn: $e");
      return null;
    }
  }

  Future<List<CategoryFood>> getAllCategories() async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      final result = await conn.execute(
        '''
        SELECT * FROM category
        ''',
      );

      return result.map((row) => CategoryFood.fromRow(row)).toList();
    } catch (e) {
      print("lỗ phần lấy tất cả thể loại đồ ăn: $e");
      return [];
    }
  }

  Future<InfoPublicUserModel?> getInfoUser(int id) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      final result = await conn.execute(
        Sql.named('''
            SELECT id, username, email FROM users WHERE id = @id
        '''),
        parameters: {'id': id},
      );

      if (result.isEmpty) return null;
      
      return InfoPublicUserModel.fromRow(result.first);
    } catch (e) {
      print("lỗ phần lấy thông tin người dùng: $e");
      return null;
    }
  }
}