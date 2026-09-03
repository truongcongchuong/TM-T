// lib/features/order_management/widgets/bill_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/models/bill_manager_model.dart';
import 'package:frontend/core/models/food_bill_item_model.dart';
import 'package:frontend/core/enum/status.dart';
import 'package:frontend/features/restaurant/services/manager_bill_service.dart';
import 'package:frontend/core/config/config.dart';

class BillDetailDialog extends StatefulWidget {
  final BillManagerModel bill;
  final String token;
  final String Function(DateTime) formatDate;

  const BillDetailDialog({
    super.key,
    required this.bill,
    required this.token,
    required this.formatDate,
  });

  @override
  State<BillDetailDialog> createState() => _BillDetailDialogState();
}

class _BillDetailDialogState extends State<BillDetailDialog> {
  final ManagerBillsServices _billService = ManagerBillsServices();

  List<FoodBillItemModel> foodItems = [];
  double totalAmount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFoodItems();
  }

  Future<void> loadFoodItems() async {
    try {
      final items = await _billService.loadFoodItem(
        widget.token,
        widget.bill.id,
      );

      double total = 0;
      for (var item in items!) {
        total += item.food.price * item.quantity;
      }

      setState(() {
        foodItems = items;
        totalAmount = total;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(thickness: 1),
            const SizedBox(height: 8),

            _buildInfoRow(Icons.person, 'Khách hàng', widget.bill.customer),
            _buildInfoRow(Icons.payment, 'Phương thức', widget.bill.paymentMethod),
            _buildInfoRow(Icons.location_on, 'Địa chỉ', widget.bill.address),

            _buildInfoRow(
              Icons.shopping_bag,
              'Trạng thái đơn',
              widget.bill.statusBill.value,
              color: _getStatusColor(widget.bill.statusBill),
            ),

            _buildInfoRow(
              Icons.attach_money,
              'Thanh toán',
              widget.bill.statusPayment.value,
              color: widget.bill.statusPayment == PaymentStatusEnum.paid
                  ? Colors.green
                  : Colors.red,
            ),

            _buildInfoRow(
              Icons.calendar_today,
              'Ngày tạo',
              widget.formatDate(widget.bill.orderTime),
            ),

            const SizedBox(height: 16),

            const Text(
              'Danh sách món ăn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildItemsList(),
            ),

            const Divider(thickness: 1),

            _buildTotalRow(),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đóng', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.receipt_long, color: Colors.red, size: 28),
        const SizedBox(width: 8),
        Text(
          'Đơn hàng #${widget.bill.id}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ================= INFO =================
  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black87,
                fontWeight: color != null ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ITEMS =================
  Widget _buildItemsList() {
    if (foodItems.isEmpty) {
      return const Center(child: Text('Không có chi tiết món ăn'));
    }

    return ListView.separated(
      itemCount: foodItems.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final item = foodItems[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red.shade50,
            child: Text(
              '${item.quantity}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          title: Text(item.food.name),
          subtitle: Text(
            '${item.quantity} x ${formatCurrency(item.food.price)}',
          ),
          trailing: Text(
            formatCurrency(item.food.price * item.quantity),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

  // ================= TOTAL =================
  Widget _buildTotalRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tổng cộng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            formatCurrency(totalAmount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATUS COLOR =================
  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.completed:
        return Colors.green;
      case OrderStatusEnum.pending:
        return Colors.orange;
      case OrderStatusEnum.delivering:
        return Colors.blue;
      case OrderStatusEnum.cancelled:
        return Colors.red;
      case OrderStatusEnum.confirmed:
        return Colors.purple;
    }
  }
}