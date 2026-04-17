import 'package:backend/shared/models/food_model.dart';
import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';

class RecommendService {

  Future<List<FoodModel>> getRecommendations(int foodIdInput) async {

    final conn = await DatabaseConfig.connection();

    try {

      // 1. ALSO BOUGHT
      final alsoBought = await conn.execute(
        Sql.named('''
          SELECT db2.food_id, COUNT(*) * 3 AS score
          FROM detail_bill db1
          JOIN detail_bill db2 
            ON db1.bill_id = db2.bill_id 
            AND db1.food_id != db2.food_id
          WHERE db1.food_id = @food_id
          GROUP BY db2.food_id
        '''),
        parameters: {'food_id': foodIdInput},
      );

      // 2. SAME CATEGORY
      final category = await conn.execute(
        Sql.named( '''
        SELECT f2.id AS food_id, 1 AS score
        FROM foods f1
        JOIN foods f2 
          ON f1.category_id = f2.category_id
        WHERE f1.id = @food_id
          AND f2.id != @food_id
        ''')
       ,
        parameters: {"food_id": foodIdInput},
      );

      // 3. TRENDING
      final trending = await conn.execute('''
        SELECT db.food_id, COUNT(*) * 0.5 AS score
        FROM detail_bill db
        JOIN bills b ON b.id = db.bill_id
        WHERE b.order_time >= NOW() - INTERVAL '7 days'
        GROUP BY db.food_id
      ''');

      // 🔥 COMBINE SCORE
      final Map<int, double> scoreMap = {};

      void addScore(List<ResultRow> rows) {
        for (var row in rows) {

          final data = row.toColumnMap();

          final int foodId = int.parse(data['food_id'].toString());
          final double score = double.parse(data['score'].toString());

          if (foodId == foodIdInput) continue;

          scoreMap[foodId] = (scoreMap[foodId] ?? 0) + score;
        }
      }

      addScore(alsoBought);
      addScore(category);
      addScore(trending);

      // SORT
      final sorted = scoreMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topIds = sorted.take(10).map((e) => e.key).toList();

      if (topIds.isEmpty) return [];

      // GET FOOD LIST
      final foods = await conn.execute(
        Sql.named('''
        SELECT * FROM foods
        WHERE id = ANY(@topId::int[])
        '''),
        parameters: {"topId": topIds},
      );

      return foods.map((row) => FoodModel.fromRow(row)).toList();

    } catch (e) {
      print('Error in getRecommendations: $e');
      return [];
    }
  }
}