import 'package:backend/roles/restaurant/models/revenue_over_time_chart.dart';
import 'package:postgres/postgres.dart';
import 'package:backend/core/config/database.dart';
import 'package:backend/shared/enum/status_enum.dart';
import 'package:backend/roles/restaurant/enum/type_time_group.dart';
import '../models/order_over_time_chart_model.dart';
import 'package:backend/roles/restaurant/models/order_status_chart_model.dart';
import 'package:backend/roles/restaurant/models/top_selling_chart_model.dart';

class DashboardChartService {

  Future<RevenueOverTimeChart> getRevenueOverTime(
    int ownerId, {
    required String unit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named('''
      WITH calendar AS (
      SELECT generate_series(
        date_trunc(@unit::text, @start::timestamp),
        date_trunc(@unit::text, (@end::timestamp - interval '1 second')),
        CASE
          WHEN @unit = 'hour' THEN interval '1 hour'
          WHEN @unit = 'day' THEN interval '1 day'
          WHEN @unit = 'month' THEN interval '1 month'
        END
      ) AS time
    ),
    revenue AS (
      SELECT 
        date_trunc(@unit::text, b.order_time) AS time,
        SUM(d.quantity * f.price) AS revenue
      FROM bills b
      JOIN detail_bill d ON d.bill_id = b.id
      JOIN foods f ON f.id = d.food_id
      JOIN restaurants r ON r.id = f.restaurant_id
      JOIN status s ON b.status_id = s.id
      WHERE r.owner = @ownerId
        AND s.name = @completedStatus
        AND b.order_time >= @start::timestamp
        AND b.order_time < @end::timestamp
      GROUP BY date_trunc(@unit::text, b.order_time)
    )
    SELECT 
      c.time,
      COALESCE(r.revenue, 0) AS revenue
    FROM calendar c
    LEFT JOIN revenue r ON r.time = c.time
    ORDER BY c.time;
      '''),
      parameters: {
        'ownerId': ownerId,
        'completedStatus': OrderStatusEnum.completed.value,
        'start': startDate,
        'end': endDate,
        'unit': unit
      },
    );

    return RevenueOverTimeChart.fromRow(result);
  }

  Future<OrderOverTimeChartModel> getOrderOverTime(
    int ownerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named('''
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
            JOIN restaurants r ON r.id = f.restaurant_id
            WHERE r.owner = @ownerId
              AND (
                @startDate::timestamp IS NULL 
                OR b.order_time >= @startDate::timestamp
              )
              AND (
                @endDate::timestamp IS NULL 
                OR b.order_time <= @endDate::timestamp
              )
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
      '''),
      parameters: {
        'ownerId': ownerId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    return OrderOverTimeChartModel.fromRow(result);
  }

  Future<OrderStatusChartModel> getOrderStatus(
    int ownerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named('''
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
        JOIN restaurants r ON r.id = f.restaurant_id
        WHERE r.owner = @ownerId 
          AND s.domain_id = 2
          AND (
            @startDate::timestamp IS NULL 
            OR b.order_time >= @startDate::timestamp
          )
          AND (
            @endDate::timestamp IS NULL 
            OR b.order_time <= @endDate::timestamp
          )
        GROUP BY s.name;
      '''),
      parameters: {
        'ownerId': ownerId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    return OrderStatusChartModel.fromRow(result);
  }

  Future<TopSellingChartModel> getTopSellingFoods(
    int ownerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conn = await DatabaseConfig.connection();

    final result = await conn.execute(
      Sql.named('''
        WITH foods_of_restaurant AS (
          SELECT f.name, f.id
          FROM foods f
          JOIN restaurants r ON r.id = f.restaurant_id 
          WHERE r.owner = @ownerId
        ),
        top_selling_rank AS (
          SELECT f.id,
                SUM(db.quantity * f.price) AS revenue,
                COUNT(*) AS total_order
          FROM detail_bill db
          JOIN foods f ON db.food_id = f.id
          JOIN restaurants r ON r.id = f.restaurant_id
          JOIN bills b ON b.id = db.bill_id
          WHERE r.owner = @ownerId
            AND (
              @startDate::timestamp IS NULL 
              OR b.order_time >= @startDate::timestamp
            )
            AND (
              @endDate::timestamp IS NULL 
              OR b.order_time <= @endDate::timestamp
            )
          GROUP BY f.id
        )
        SELECT 
          ft.name,
          COALESCE(ts.revenue, 0) AS revenue,
          COALESCE(ts.total_order, 0) AS total_order
        FROM foods_of_restaurant ft
        LEFT JOIN top_selling_rank ts ON ft.id = ts.id
        ORDER BY revenue DESC;
      '''),
      parameters: {
        'ownerId': ownerId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    return TopSellingChartModel.fromRow(result);
  }
}