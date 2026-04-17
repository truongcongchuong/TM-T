import 'package:frontend/core/enum/status.dart';
class OrderStatusDataPoint {
  final OrderStatusEnum status;
  final int totalOrder;
  final double percentage;

  OrderStatusDataPoint({
    required this.status,
    required this.totalOrder,
    required this.percentage,
  });

  factory OrderStatusDataPoint.fromMap(Map<String, dynamic> map) {
    return OrderStatusDataPoint(
      status: OrderStatusEnum.fromString(map['status']),
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
}

class OrderStatusChartModel {
  final String title;
  final List<OrderStatusDataPoint> dataPoints;

  OrderStatusChartModel({
    required this.dataPoints,
    required this.title,  
  });

  factory OrderStatusChartModel.fromMap(Map<String, dynamic> map) {
    return OrderStatusChartModel(
      title: map['title']?.toString() ?? "Tình trạng đơn hàng",
      dataPoints: (map['data_points'] as List?)
          ?.map((map) => OrderStatusDataPoint.fromMap(map))
          .toList() ??
          [],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "data_points": dataPoints.map((e) => e.toMap()).toList(),
    };
  }
}