import 'package:frontend/core/config/config.dart';
import 'package:frontend/core/models/dashboard_overview_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardOverviewServices {

  Future<DashboardOverviewModel> getOverview(
    String token, {
    String period = "month",
    String? startDate,
    String? endDate,
  }) async {

    final uri = Uri.parse(
      '$baseUrl/restaurant/dashboard/overview'
    ).replace(
      queryParameters: {
        'period': period,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        ...headers,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DashboardOverviewModel.fromMap(
        jsonDecode(response.body)['data'],
      );
    } else {
      throw Exception('Failed to load dashboard overview');
    }
  }
}