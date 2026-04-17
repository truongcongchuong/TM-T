import 'package:shelf/shelf.dart';
import '../../../core/utils/response.dart';
import '../services/dashboard_service.dart';
import 'package:backend/shared/enum/user_role_enum.dart';
import 'package:backend/roles/restaurant/services/dashboard_chart_service.dart';
import 'package:backend/roles/restaurant/enum/type_time_group.dart';

class DashboardController {
  final DashboardService dashboardService = DashboardService();
  final DashboardChartService dashboardChartService = DashboardChartService();

  Future<Response> getoverView(Request req) async {
    final restaurantId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final overview = await dashboardService.getOverview(restaurantId);
    
    return ResponseUtil.success(overview.toMap());
  }

  Future<Response> getDataRevenueOverTimeChart(Request req, String timeGroup) async {
    final restaurantId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }
    final TypeTimeGroup typeTimeGroup = TypeTimeGroup.fromString(timeGroup);

    final revenue = await dashboardChartService.getRevenueOverTime(restaurantId, typeTimeGroup);
    
    return ResponseUtil.success(revenue.toMap());
  }

  Future<Response> getDataOrderOverTimeChart(Request req) async {
    final restaurantId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final ordersOverTime = await dashboardChartService.getOrderOverTime(restaurantId);
    
    return ResponseUtil.success(ordersOverTime.toMap());
  }

  Future<Response> getDataOrderStatusChart(Request req) async {
    final restaurantId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final orderStatusData = await dashboardChartService.getOrderStatus(restaurantId);
    
    return ResponseUtil.success(orderStatusData.toMap());
  }

  Future<Response> getDataTopSellingChart(Request req) async {
    final restaurantId = req.context['userId'] as int?;
    final role = req.context['role'] as String?;

    if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
      return ResponseUtil.unauthorized();
    }

    final topSellingData = await dashboardChartService.getTopSellingFoods(restaurantId);
    
    return ResponseUtil.success(topSellingData.toMap());
  }
  
}
