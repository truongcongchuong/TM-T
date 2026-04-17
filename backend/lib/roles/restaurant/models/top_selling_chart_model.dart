import 'package:postgres/postgres.dart';

class TopSellingDataPoint {
  final String name;
  final int totalSold;
  final double revenue;

  TopSellingDataPoint({
    required this.name,
    required this.totalSold,
    required this.revenue,

  });

  factory TopSellingDataPoint.fromMap(Map<String, dynamic> map) {
    return TopSellingDataPoint(
      name: map['name']?.toString() ?? '',
      totalSold: map['total_sold'] is num
          ? (map['total_sold'] as num).toInt()
          : int.tryParse(map['total_sold']?.toString() ?? '0') ?? 0,
      revenue: map['revenue'] is num
          ? (map['revenue'] as num).toDouble()
          : double.tryParse(map['revenue']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "total_sold": totalSold,
      "revenue": revenue,
    };
  }

  factory TopSellingDataPoint.fromRow(ResultRow row) {
    return TopSellingDataPoint.fromMap(row.toColumnMap());
  }
}
class TopSellingChartModel {
  final title = "Món bán chạy";
  final List<TopSellingDataPoint> dataPoints;

  TopSellingChartModel({
    required this.dataPoints,
  });

  factory TopSellingChartModel.fromMap(List<Map<String, dynamic>> list) {
    return TopSellingChartModel(
      dataPoints: list.map((map) => TopSellingDataPoint.fromMap(map)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "data_points": dataPoints.map((e) => e.toMap()).toList(),
    };
  }

  factory TopSellingChartModel.fromRow(List<ResultRow> rows) {
    final dataPoints = rows.map((row) => TopSellingDataPoint.fromRow(row)).toList();
    return TopSellingChartModel(dataPoints: dataPoints);
  }
}