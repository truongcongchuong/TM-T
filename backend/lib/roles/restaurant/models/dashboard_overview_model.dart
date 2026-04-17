import 'package:postgres/postgres.dart';

class DashboardOverviewModel {
  final int totalSold;
  final double totalRevenue;
  final int totalFood;
  final int completedOrders;
  final int pendingOrders;
  final int cancelledOrders;
  final int customers;

  DashboardOverviewModel({
    required this.totalSold,
    required this.totalRevenue,
    required this.totalFood,
    required this.completedOrders,
    required this.pendingOrders,
    required this.cancelledOrders,
    required this.customers,
  });

  factory DashboardOverviewModel.fromMap(Map<String, dynamic> map) {
    return DashboardOverviewModel(
      totalSold: map['total_sold'] as int? ?? 0,
      totalRevenue: map['total_revenue'] is num
          ? (map['total_revenue'] as num).toDouble()
          : double.tryParse(map['total_revenue']?.toString() ?? '0') ?? 0.0,
      totalFood: map['total_products'] as int? ?? 0,
      completedOrders: map['completed_orders'] as int? ?? 0,
      pendingOrders: map['pending_orders'] as int? ?? 0,
      cancelledOrders: map['cancelled_orders'] as int? ?? 0,
      customers: map['customers'] as int? ?? 0,
    );
  }

  factory DashboardOverviewModel.fromRow(ResultRow row) {
    return DashboardOverviewModel.fromMap(row.toColumnMap());
  }

  Map<String, dynamic> toMap() {
    return {
      "total_sold": totalSold,
      "total_revenue": totalRevenue,
      "total_products": totalFood,
      "completed_orders": completedOrders,
      "pending_orders": pendingOrders,
      "cancelled_orders": cancelledOrders,
      "customers": customers,
    };
  }
}