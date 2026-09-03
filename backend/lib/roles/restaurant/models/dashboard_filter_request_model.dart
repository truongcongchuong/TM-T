enum DashboardFilterType {
  week,
  month,
  year,
  custom,
}

class DashboardFilterRequest {
  final DashboardFilterType type;
  final DateTime? startDate;
  final DateTime? endDate;

  DashboardFilterRequest({
    required this.type,
    this.startDate,
    this.endDate,
  });

  factory DashboardFilterRequest.fromJson(Map<String, dynamic> json) {
    return DashboardFilterRequest(
      type: DashboardFilterType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
    );
  }
}