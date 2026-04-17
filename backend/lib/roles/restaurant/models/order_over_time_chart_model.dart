import 'package:postgres/postgres.dart';
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
      "total_orders": totalOrders,
    };
  }

  factory OrderOverTimeDataPoint.fromRow(ResultRow row) {
    final data = row.toColumnMap();
    const Map<int, String> dayMap = {
      0: "Chủ nhật",
      1: "Thứ 2",
      2: "Thứ 3",
      3: "Thứ 4",
      4: "Thứ 5",
      5: "Thứ 6",
      6: "Thứ 7",
    }; // chuyển sang map theo tên cột
    data['day_of_week'] = dayMap[data['day_of_week']] ?? 'Unknown';
    return OrderOverTimeDataPoint.fromMap(data);
  }
}

class OrderOverTimeChartModel {
  final String title;
  final List<OrderOverTimeDataPoint> dataPoints;

  OrderOverTimeChartModel({
    this.title = "Số lượng đơn hàng theo thời gian",
    required this.dataPoints,
  });

  factory OrderOverTimeChartModel.fromMap(List<Map<String, dynamic>> list) {
    return OrderOverTimeChartModel(
      dataPoints: list.map((map) => OrderOverTimeDataPoint.fromMap(map)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "data_points": dataPoints.map((e) => e.toMap()).toList(),
    };
  }

  factory OrderOverTimeChartModel.fromRow(List<ResultRow> rows) {
    final dataPoints = rows.map((row) => OrderOverTimeDataPoint.fromRow(row)).toList();
    return OrderOverTimeChartModel(dataPoints: dataPoints);
  }
}