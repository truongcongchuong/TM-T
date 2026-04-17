import 'package:frontend/core/config/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/bill_manager_model.dart';
import 'package:flutter/foundation.dart';

class ManagerBillsServices {

  Future<List<BillManagerModel>> getBills(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurant/manager/bills'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return compute(_parseBills, response.body);
    } else {
      throw Exception('Failed to load manager bills');
    }
  }
  List<BillManagerModel> _parseBills(String body) {
    final data = jsonDecode(body)['data'] as List;

    return data
        .map((e) => BillManagerModel.fromMap(e))
        .toList();
  }
}