import './dashboard_filter_request_model.dart';
class TimeRangeResult {
  final DateTime start;
  final DateTime end;
  final String unit;

  TimeRangeResult(this.start, this.end, this.unit);
}

TimeRangeResult resolveTimeRange(DashboardFilterRequest req) {
  final now = DateTime.now();

  String  resolveUnit(DateTime start, DateTime end) {
    final diff = end.difference(start).inDays;

    if (diff <= 1) return 'hour';
    if (diff <= 60) return 'day';
    if (diff <= 365) return 'month';
    return 'year';
  }
  switch (req.type) {
    case DashboardFilterType.week:
      final start = now.subtract(Duration(days: now.weekday - 1));
      return TimeRangeResult(
        DateTime(start.year, start.month, start.day),
        DateTime(start.year, start.month, start.day)
            .add(const Duration(days: 7)),
        'day',
      );

    case DashboardFilterType.month:
      return TimeRangeResult(
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 1),
        'day',
      );

    case DashboardFilterType.year:
      return TimeRangeResult(
        DateTime(now.year, 1, 1),
        DateTime(now.year + 1, 1, 1),
        'month',
      );

    case DashboardFilterType.custom:
      if (req.startDate == null || req.endDate == null) {
        throw Exception("Custom mode requires startDate & endDate");
      }

      return TimeRangeResult(
        req.startDate!,
        req.endDate!,
        resolveUnit(req.startDate!, req.endDate!),
      );
  }
}