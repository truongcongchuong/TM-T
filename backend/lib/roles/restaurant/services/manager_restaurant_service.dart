import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import '../../../shared/models/restaurant_model.dart';

class ManagerInfoRestaurantService {

  Future<RestaurantModel?> getInfoRestaurant(int ownerId) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        SELECT *
        FROM restaurants r
        WHERE r.owner = @ownerId
        LIMIT 1;
        '''
      ),
      parameters: {
        'ownerId': ownerId,
      },
    );

    if (result.isEmpty) {
      return null; // không có dữ liệu
    }
    return RestaurantModel.fromRow(result.first);
  }

  Future<bool> updateInfo(RestaurantModel restaurant) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        UPDATE restaurants
        SET
          name = @name,
          address = COALESCE(@address, address),
          is_open = COALESCE(@isOpen, is_open),
          latitude = COALESCE(@latitude, latitude),
          longitude = COALESCE(@longitude, longitude)
        WHERE id = @id
        '''
      ),
      parameters: {
        'id': restaurant.id,
        'name': restaurant.name,
        'address': restaurant.address,
        'isOpen': restaurant.isOpen,
        'latitude': restaurant.latitude,
        'longitude': restaurant.longitude,
      },
    );

    // rowCount là cách đúng để check update
    return result.affectedRows > 0;
  }
}