class OrderOverTimeDataPoint {
  final String dayOfWeek;
  final int hour;
  final int totalOrders;

  OrderOverTimeDataPoint({
    required this.dayOfWeek,
    required this.hour,
    required this.totalOrders,
  });

  factory OrderOverTimeDataPoint.fromMap(Map<String, dynamic> map) {
    return OrderOverTimeDataPoint(
      dayOfWeek: map['day_of_week'] as String,
      hour: map['hour'] is num
          ? (map['hour'] as num).toInt()
          : int.tryParse(map['hour']?.toString() ?? '0') ?? 0,
      totalOrders: map['total_orders'] is num
          ? (map['total_orders'] as num).toInt()
          : int.tryParse(map['total_orders']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "day_of_week": dayOfWeek,
      "hour": hour,
      "total_order": totalOrders,
    };
  }
}

class OrderOverTimeChart {
  final String title;
  final List<OrderOverTimeDataPoint> dataPoints;

  OrderOverTimeChart({
    required this.title,
    required this.dataPoints,
  });

  factory OrderOverTimeChart.fromMap(Map<String, dynamic> map) {
    return OrderOverTimeChart(
      title: map["title"] as String,
      dataPoints: (map["data_points"] as List)
          .map((data) => OrderOverTimeDataPoint.fromMap(data))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "data_points": dataPoints.map((e) => e.toMap()).toList(),
    };
  }
}