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
}
class TopSellingChartModel {
  final String  title;
  final List<TopSellingDataPoint> dataPoints;

  TopSellingChartModel({
    required this.dataPoints,
    required this.title,
  });

  factory TopSellingChartModel.fromMap(Map<String, dynamic> map) {
    return TopSellingChartModel(
      title: map["title"]?.toString() ?? "Món bán chạy",
      dataPoints: (map["data_points"] as List<dynamic>?)
          ?.map((e) => TopSellingDataPoint.fromMap(e as Map<String, dynamic>))
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