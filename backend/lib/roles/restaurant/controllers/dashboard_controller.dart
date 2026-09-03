import 'package:shelf/shelf.dart';
import '../../../core/utils/response.dart';
import '../services/dashboard_service.dart';
import 'package:backend/shared/enum/user_role_enum.dart';
import 'package:backend/roles/restaurant/services/dashboard_chart_service.dart';

class DashboardController {
  final DashboardService dashboardService = DashboardService();
  final DashboardChartService dashboardChartService = DashboardChartService();

  (DateTime start, DateTime end, String unit) resolveTime(
    String type,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final now = DateTime.now();

    // 🔥 CUSTOM
    if (startDate != null && endDate != null) {
      final diff = endDate.difference(startDate).inDays;

      if (diff <= 1) return (startDate, endDate, 'hour');
      if (diff <= 60) return (startDate, endDate, 'day');
      if (diff <= 365) return (startDate, endDate, 'month');

      return (startDate, endDate, 'year');
    }

    // 🔥 PRESET
    switch (type) {
      case 'day':
        final start = DateTime(now.year, now.month, now.day);
        return (start, start.add(const Duration(days: 1)), 'hour');

      case 'week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        final s = DateTime(start.year, start.month, start.day);
        return (s, s.add(const Duration(days: 7)), 'day');

      case 'month':
        final start = DateTime(now.year, now.month, 1);
        return (start, DateTime(now.year, now.month + 1, 1), 'day');

      case 'year':
        final start = DateTime(now.year, 1, 1);
        return (start, DateTime(now.year + 1, 1, 1), 'month');

      default:
        final start = DateTime(now.year, now.month, 1);
        return (start, DateTime(now.year, now.month + 1, 1), 'day');
    }
  }

  // ================= OVERVIEW =================
  Future<Response> getoverView(Request req) async {
    final ownerId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (ownerId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final query = req.url.queryParameters;

    final startDate = query['startDate'] != null
        ? DateTime.tryParse(query['startDate']!)
        : null;

    final endDate = query['endDate'] != null
        ? DateTime.tryParse(query['endDate']!)
        : null;

    final period = query['period'] == null? "": query['period'] as String;

    final (start, end, unit) = resolveTime(
      period,
      startDate,
      endDate,
    );

    final overview = await dashboardService.getOverview(
      ownerId,
      startDate: start,
      endDate: end,
    );

    return ResponseUtil.success(overview.toMap());
  }

  // ================= REVENUE (GIỮ timeGroup) =================
  Future<Response> getDataRevenueOverTimeChart(Request req) async {
    final ownerId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (ownerId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final query = req.url.queryParameters;

    final period = query['period'] ?? 'day';
    final startDate = query['startDate'] != null
        ? DateTime.tryParse(query['startDate']!)
        : null;
    final endDate = query['endDate'] != null
        ? DateTime.tryParse(query['endDate']!)
        : null;

    
    final (start, end, unit) = resolveTime(
      period,
      startDate,
      endDate,
    );
    final revenue = await dashboardChartService.getRevenueOverTime(
      ownerId,
      unit: unit,
      startDate: start,
      endDate: end,
    );
    print("revice ${revenue.toMap()}"); 
    return ResponseUtil.success(revenue.toMap());
  }

  // ================= ORDER OVER TIME (BỎ timeGroup) =================
  Future<Response> getDataOrderOverTimeChart(Request req) async {
    final ownerId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (ownerId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final query = req.url.queryParameters;

    final period = query['period'] == null? "": query['period'] as String;
    final startDate = query['startDate'] != null
        ? DateTime.tryParse(query['startDate']!)
        : null;

    final endDate = query['endDate'] != null
        ? DateTime.tryParse(query['endDate']!)
        : null;

    final (start, end, unit) = resolveTime(
      period,
      startDate,
      endDate,
    );

    final data = await dashboardChartService.getOrderOverTime(
      ownerId,
      startDate: start,
      endDate: end,
    );

    return ResponseUtil.success(data.toMap());
  }

  // ================= ORDER STATUS =================
  Future<Response> getDataOrderStatusChart(Request req) async {
    final ownerId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (ownerId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final query = req.url.queryParameters;

    final startDate = query['startDate'] != null
        ? DateTime.tryParse(query['startDate']!)
        : null;

    final endDate = query['endDate'] != null
        ? DateTime.tryParse(query['endDate']!)
        : null;
    final period = query['period'] == null? "": query['period'] as String;

    final (start, end, unit) = resolveTime(
      period,
      startDate,
      endDate,
    );
    final data = await dashboardChartService.getOrderStatus(
      ownerId,
      startDate: start,
      endDate: end,
    );

    return ResponseUtil.success(data.toMap());
  }

  // ================= TOP SELLING =================
  Future<Response> getDataTopSellingChart(Request req) async {
    final ownerId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (ownerId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final query = req.url.queryParameters;

    final startDate = query['startDate'] != null
        ? DateTime.tryParse(query['startDate']!)
        : null;

    final endDate = query['endDate'] != null
        ? DateTime.tryParse(query['endDate']!)
        : null;

    final period = query['period'] == null? "": query['period'] as String;

    final (start, end, unit) = resolveTime(
      period,
      startDate,
      endDate,
    );
    final data = await dashboardChartService.getTopSellingFoods(
      ownerId,
      startDate: start,
      endDate: end,
    );

    return ResponseUtil.success(data.toMap());
  }
}