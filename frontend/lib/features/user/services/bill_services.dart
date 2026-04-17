import 'dart:convert';
import 'package:frontend/core/models/bill.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/config/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';

class BillServices {
  Future<List<Bill>> getBillsByUserId(BuildContext context, int userId) async {
    final url = Uri.parse('$baseUrl/user/bills');
    final token = context.read<AuthProvider>().token;

    final response = await http.get(
      url,
      headers: {
        ...headers,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List<dynamic> billsData = jsonData['data'];
      final bills = billsData
          .map((billData) => Bill.fromJson(billData as Map<String, dynamic>))
          .toList();
      return bills;
    } else {
      throw Exception('Failed to load bills');
    }
  }
}
