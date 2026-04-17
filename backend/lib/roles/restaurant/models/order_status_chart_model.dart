import 'package:postgres/postgres.dart';

class OrderStatusDataPoint {
  final String status;
  final int totalOrder;
  final double percentage;

  OrderStatusDataPoint({
    required this.status,
    required this.totalOrder,
    required this.percentage,
  });

  factory OrderStatusDataPoint.fromMap(Map<String, dynamic> map) {
    return OrderStatusDataPoint(
      status: map['status']?.toString() ?? '',
      totalOrder: map['total_order'] is num
          ? (map['total_order'] as num).toInt()
          : int.tryParse(map['total_order']?.toString() ?? '0') ?? 0,
      percentage: map['percentage'] is num
          ? (map['percentage'] as num).toDouble()
          : double.tryParse(map['percentage']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "status": status,
      "total_order": totalOrder,
      "percentage": percentage,
    };
  }

  factory OrderStatusDataPoint.fromRow(ResultRow row) {
    return OrderStatusDataPoint.fromMap(row.toColumnMap());
  }
}

class OrderStatusChartModel {
  final title = "Tình trạng đơn hàng";
  final List<OrderStatusDataPoint> dataPoints;

  OrderStatusChartModel({
    required this.dataPoints,
  });

  factory OrderStatusChartModel.fromMap(List<Map<String, dynamic>> list) {
    return OrderStatusChartModel(
      dataPoints: list.map((map) => OrderStatusDataPoint.fromMap(map)).toList(),
    );
  }

  factory OrderStatusChartModel.fromRow(List<ResultRow> rows) {
    final dataPoints = rows.map((row) => OrderStatusDataPoint.fromRow(row)).toList();
    return OrderStatusChartModel(dataPoints: dataPoints);
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "data_points": dataPoints.map((e) => e.toMap()).toList(),
    };
  }
}