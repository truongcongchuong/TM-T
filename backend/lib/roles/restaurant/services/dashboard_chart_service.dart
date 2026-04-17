import 'package:backend/roles/restaurant/models/revenue_over_time_chart.dart';
import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import 'package:backend/shared/enum/status_enum.dart';
import 'package:backend/roles/restaurant/enum/type_time_group.dart';
import '../models/order_over_time_chart_model.dart';
import 'package:backend/roles/restaurant/models/order_status_chart_model.dart';
import 'package:backend/roles/restaurant/models/top_selling_chart_model.dart';

class DashboardChartService {

  Future<RevenueOverTimeChart> getRevenueOverTime(int restaurantId, TypeTimeGroup timeGroup) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        SELECT 
            DATE_TRUNC('${timeGroup.value}', b.order_time) AS time,
            SUM(d.quantity * f.price) AS revenue
        FROM bills b
        JOIN detail_bill d ON d.bill_id = b.id
        JOIN foods f ON f.id = d.food_id
        JOIN status st ON b.status_id = st.id
        WHERE f.restaurant_id = @restaurantId
          AND st.name = @completedStatus
          AND DATE(b.order_time) BETWEEN '2026-04-01' AND '2026-04-30'
        GROUP BY DATE_TRUNC('${timeGroup.value}', b.order_time)
        ORDER BY time;
        '''
      ),
      parameters: {
        'restaurantId': restaurantId,
        'completedStatus': OrderStatusEnum.completed.value,
      },
    );


    return RevenueOverTimeChart.fromRow(result);
  }

  Future<OrderOverTimeChartModel> getOrderOverTime(int restaurantId) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
        WITH days AS (
            SELECT generate_series(0, 6) AS day_of_week
        ),
        hours AS (
            SELECT generate_series(0, 23) AS hour
        ),

        grid AS (
            SELECT d.day_of_week, h.hour
            FROM days d
            CROSS JOIN hours h
        ),

        orders AS (
            SELECT 
                EXTRACT(DOW FROM b.order_time) AS day_of_week,
                EXTRACT(HOUR FROM b.order_time) AS hour,
                COUNT(*) AS total_orders
            FROM bills b
          JOIN detail_bill db ON b.id = db.bill_id
          JOIN foods f ON db.food_id = f.id
          WHERE f.restaurant_id = @restaurantId
            GROUP BY day_of_week, hour
        )

        SELECT 
            g.day_of_week,
            g.hour,
            COALESCE(o.total_orders, 0) AS total_orders
        FROM grid g
        LEFT JOIN orders o
            ON g.day_of_week = o.day_of_week
          AND g.hour = o.hour
        ORDER BY g.day_of_week, g.hour;
        '''
      ),
      parameters: {
        'restaurantId': restaurantId,
      },
    );

    return OrderOverTimeChartModel.fromRow(result);
  }

  Future<OrderStatusChartModel> getOrderStatus(int restaurantId) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
            SELECT 
                s.name AS status,
                COUNT(DISTINCT b.id) AS total_orders,
                ROUND(
                    COUNT(DISTINCT b.id) * 100.0 
                    / SUM(COUNT(DISTINCT b.id)) OVER (),
                    2
                ) AS percentage
            FROM bills b 
            JOIN detail_bill db ON b.id = db.bill_id
            JOIN foods f ON db.food_id = f.id 
            JOIN status s ON s.id = b.status_id
            WHERE f.restaurant_id = @restaurantId AND s.domain_id = 2
            GROUP BY s.name;
        '''
      ),
      parameters: {
        'restaurantId': restaurantId,
      },
    );

    return OrderStatusChartModel.fromRow(result);
  }

  Future<TopSellingChartModel> getTopSellingFoods(int restaurantId) async {
    final Connection conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named(
        '''
          WITH foods_of_restaurant AS (
            SELECT f.name, f.id
            FROM foods f
            JOIN users u ON f.restaurant_id = u.id
            WHERE u.id = @restaurantId
          ),

          top_selling_rank AS (
            SELECT f.id , SUM(db.quantity * f.price) AS revenue, COUNT(*) AS total_order
            FROM detail_bill db
            JOIN foods f ON db.food_id = f.id
            WHERE f.restaurant_id = @restaurantId
            GROUP BY f.id
          )

          SELECT 
            ft.name,
            COALESCE(ts.revenue, 0) AS revenue,
            COALESCE(ts.total_order, 0) AS total_order
          FROM foods_of_restaurant ft
          LEFT JOIN top_selling_rank ts ON ft.id = ts.id
          ORDER BY revenue DESC;
        '''
      ),
      parameters: {
        'restaurantId': restaurantId,
      },
    );

    return TopSellingChartModel.fromRow(result);
  }
}