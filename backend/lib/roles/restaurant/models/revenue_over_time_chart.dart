import 'package:postgres/postgres.dart';

class RevenueDataPoint {
  final DateTime time;
  final double revenue;

  RevenueDataPoint({
    required this.time,
    required this.revenue,
  });

  factory RevenueDataPoint.fromMap(Map<String, dynamic> map) {
    return RevenueDataPoint(
      time: map['time'] is DateTime
          ? map['time'] as DateTime
          : DateTime.parse(map['time'].toString()),
      revenue: map['revenue'] is num
          ? (map['revenue'] as num).toDouble()
          : double.tryParse(map['revenue']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "time": time.toIso8601String(),
      "revenue": revenue,
    };
  }

  factory RevenueDataPoint.fromRow(ResultRow row) {
    final data = row.toColumnMap(); // chuyển sang map theo tên cột
    return RevenueDataPoint.fromMap(data);
  }
}

class RevenueOverTimeChart {
  final title = "Doanh thu theo thời gian";
  final List<RevenueDataPoint> dataPoints;

  RevenueOverTimeChart({
    required this.dataPoints,
  });

  factory RevenueOverTimeChart.fromMap(List<Map<String, dynamic>> list) {
    return RevenueOverTimeChart(
      dataPoints: list.map((map) => RevenueDataPoint.fromMap(map)).toList(),
    );
  }

  factory RevenueOverTimeChart.fromRow(List<ResultRow> rows) {
    final dataPoints = rows.map((row) => RevenueDataPoint.fromRow(row)).toList();
    return RevenueOverTimeChart(dataPoints: dataPoints);
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "data_points": dataPoints.map((e) => e.toMap()).toList(),
    };
  }
}