import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import 'package:backend/shared/models/restaurant_model.dart';

class RestaurantService {
  Future<int?> createRestaurant(RestaurantModel restaurant) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      final result = await conn.execute(
        Sql.named('''
          INSERT INTO restaurants (
            owner,
            name,
            address,
            latitude,
            longitude,
            is_open,
            rating_avg
          )
          VALUES (
            @owner,
            @name,
            @address,
            @lat,
            @lng,
            @isOpen,
            @rating
          )
          RETURNING id;
        '''),
        parameters: {
          "owner": restaurant.owner,
          "name": restaurant.name,
          "address": restaurant.address,
          "lat": restaurant.latitude,
          "lng": restaurant.longitude,
          "isOpen": restaurant.isOpen,
          "rating": restaurant.ratingAvg,
        },
      );

      return result.first[0] as int;

    } catch (e) {
      await conn.execute(
        Sql.named('''
            DELETE FROM users WHERE id = @owner
        '''),
        parameters: {
          "owner": restaurant.owner
        }
      );
      return null;
    }
  }
}