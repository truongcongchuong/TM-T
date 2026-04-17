import 'package:flutter/material.dart';
import 'package:frontend/core/models/bill.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/user/services/bill_services.dart';
import './widgets/history_oder_card.dart';

class HistoryOrderScreen extends StatefulWidget {
  const HistoryOrderScreen({super.key});

  @override
  State<HistoryOrderScreen> createState() => _HistoryOrderScreenState();
}

class _HistoryOrderScreenState extends State<HistoryOrderScreen> {
  List<Bill> bills = [];
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    loadBill();
  }

  Future<void> loadBill() async {
    final user = context.read<AuthProvider>().user!;
    final billService = BillServices();
    final listbills = await billService.getBillsByUserId(context, user.id!);
    setState(() {
      bills = listbills;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Chưa có đơn hàng nào'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng'),
        backgroundColor: const Color.fromARGB(255, 250, 242, 241),
      ),
      body: ListView.builder(
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          return HistoryOrderCard(bill: bill);
        },
      ),
    );
  }
}