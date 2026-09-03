import 'package:frontend/core/config/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/bill_manager_model.dart';
import 'package:frontend/core/models/food_bill_item_model.dart';
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

  Future<List<FoodBillItemModel>?> loadFoodItem(String token, int billId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurant/manager/bills/$billId/items'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((e) => FoodBillItemModel.fromMap(e))
          .toList();
    } else {
      return [];
    }
  }

  Future<bool> updateBill(
    String token,
    int? billId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/restaurant/manager/bills/$billId'), 
        headers: {
          ...headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}