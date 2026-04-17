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
}

class RevenueOverTimeChart {
  final title;
  final List<RevenueDataPoint> dataPoints;

  RevenueOverTimeChart({
    required this.dataPoints,
    required this.title,

  });

  factory RevenueOverTimeChart.fromMap(Map<String, dynamic> map) {
    return RevenueOverTimeChart(
      dataPoints: (map['data_points'] as List)
          .map((e) => RevenueDataPoint.fromMap(e))
          .toList(),
      title: map['title'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "data_points": dataPoints.map((e) => e.toMap()).toList(),
    };
  }
}