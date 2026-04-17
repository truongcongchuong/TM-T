import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import '../models/dashboard_overview_model.dart';
import 'package:backend/shared/enum/status_enum.dart';

class DashboardService {
  Future<DashboardOverviewModel> getOverview(int restaurantId) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        SELECT
            stats.total_sold,
            stats.total_revenue,
            products.total_products,
            stats.customers,
            stats.completed_orders,
            stats.pending_orders,
            stats.cancelled_orders
        FROM
        (
            SELECT
                COALESCE(SUM(CASE WHEN st.name = @completedStatus THEN db.quantity ELSE 0 END),0) AS total_sold,

                COALESCE(SUM(CASE WHEN st.name = @completedStatus THEN db.quantity * f.price ELSE 0 END),0) AS total_revenue,

                COUNT(DISTINCT b.user_id) AS customers,

                COUNT(DISTINCT CASE WHEN st.name = @completedStatus THEN b.id END) AS completed_orders,

                COUNT(DISTINCT CASE WHEN st.name = @pendingStatus THEN b.id END) AS pending_orders,

                COUNT(DISTINCT CASE WHEN st.name = @cancelledStatus THEN b.id END) AS cancelled_orders

            FROM detail_bill db
            JOIN foods f ON db.food_id = f.id
            JOIN bills b ON db.bill_id = b.id
            JOIN status st ON b.status_id = st.id
            WHERE f.restaurant_id = @restaurantId
        ) stats,
        (
            SELECT COUNT(*) AS total_products
            FROM foods
            WHERE restaurant_id = @restaurantId
        ) products;
        '''
      ),
      parameters: {
        'restaurantId': restaurantId,
        'completedStatus': OrderStatusEnum.completed.value,
        'pendingStatus': OrderStatusEnum.pending.value,
        'cancelledStatus': OrderStatusEnum.cancelled.value
      },
    );

    print(result.first.toColumnMap());
    return DashboardOverviewModel.fromRow(result.first);
  }
}