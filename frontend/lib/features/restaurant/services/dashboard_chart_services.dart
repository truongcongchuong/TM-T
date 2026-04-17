import 'package:frontend/core/config/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/chart_model.dart';
import 'package:frontend/core/models/order_over_time_chart_model.dart';
import 'package:frontend/core/models/order_status_chart_model.dart';
import 'package:frontend/core/models/top_selling_chart_model.dart';

class DashboardChartServices {
   Future<RevenueOverTimeChart> getRevenueOverTime(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurant/dashboard/chartRevenueOverTime/day'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200) {
      return RevenueOverTimeChart.fromMap(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load revenue over time data');
    }
  }

  Future<OrderOverTimeChart> getOrderOverTime(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurant/dashboard/chartOrderOverTime'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200) {
      return OrderOverTimeChart.fromMap(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load order over time data');
    }
  }

  Future<OrderStatusChartModel> getOrderStatus(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurant/dashboard/chartOrderStatus'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200) {
      return OrderStatusChartModel.fromMap(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load order status data');
    }
  }

  Future<TopSellingChartModel> getTopSelling(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurant/dashboard/chartTopSelling'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200) {
      return TopSellingChartModel.fromMap(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load top selling data');
    }
  }
}