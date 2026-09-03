// lib/features/order_management/widgets/bill_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/enum/status.dart';
import 'package:frontend/core/models/bill_manager_model.dart';
import 'package:frontend/features/restaurant/services/manager_bill_service.dart';
import 'package:frontend/core/models/food_bill_item_model.dart';
import "package:frontend/core/config/config.dart";

class BillEditDialog extends StatefulWidget {
  final BillManagerModel bill;
  final String token;
  final VoidCallback onRefresh;

  const BillEditDialog({
    super.key,
    required this.bill,
    required this.token,
    required this.onRefresh,
  });

  @override
  State<BillEditDialog> createState() => _BillEditDialogState();
}

class _BillEditDialogState extends State<BillEditDialog> {
  late TextEditingController addressController;
  late OrderStatusEnum selectedStatus;
  late PaymentStatusEnum selectedPayment;
  final ManagerBillsServices _billService = ManagerBillsServices();
  List<FoodBillItemModel>? foodItem = [];
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController(text: widget.bill.address);
    selectedStatus = widget.bill.statusBill;
    selectedPayment = widget.bill.statusPayment;
    loadFoodItems();
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  void loadFoodItems() async {
    final items = await _billService.loadFoodItem(widget.token, widget.bill.id);

    double total = 0;
    if (items != null) {
      for (var item in items) {
        total += item.food.price * item.quantity;
      }
    }
    setState(() {
      foodItem = items;
      totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(thickness: 1),
            const SizedBox(height: 12),
            _buildReadOnlyField('Khách hàng', widget.bill.customer),
            _buildReadOnlyField('Phương thức thanh toán', widget.bill.paymentMethod),
            _buildEditableAddressField(),
            const SizedBox(height: 12),
            _buildStatusDropdown(),
            const SizedBox(height: 12),
            _buildPaymentDropdown(),
            const SizedBox(height: 16),
            const Text('Danh sách món ăn', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(child: _buildItemsList()),
            const Divider(thickness: 1),
            _buildTotalRow(),
            const SizedBox(height: 8),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.edit_note, color: Colors.orange, size: 28),
        const SizedBox(width: 8),
        Text(
          'Chỉnh sửa đơn #${widget.bill.id}',
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

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildEditableAddressField() {
    return TextField(
      controller: addressController,
      decoration: InputDecoration(
        labelText: 'Địa chỉ giao hàng',
        prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<OrderStatusEnum>(
      value: selectedStatus,
      decoration: InputDecoration(
        labelText: 'Trạng thái đơn hàng',
        prefixIcon: const Icon(Icons.shopping_bag, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: OrderStatusEnum.values.map((e) {
        return DropdownMenuItem(value: e, child: Text(e.value));
      }).toList(),
      onChanged: (value) => setState(() => selectedStatus = value!),
    );
  }

  Widget _buildPaymentDropdown() {
    return DropdownButtonFormField<PaymentStatusEnum>(
      value: selectedPayment,
      decoration: InputDecoration(
        labelText: 'Trạng thái thanh toán',
        prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: PaymentStatusEnum.values.map((e) {
        return DropdownMenuItem(value: e, child: Text(e.value));
      }).toList(),
      onChanged: (value) => setState(() => selectedPayment = value!),
    );
  }

  Widget _buildItemsList() {
    if (foodItem != null && foodItem!.isNotEmpty) {
      return ListView.separated(
        itemCount: foodItem!.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final item = foodItem![index];
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
    } else {
      return const Text('Không có chi tiết món ăn');
    }
  }

  Widget _buildTotalRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Tổng cộng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(formatCurrency(totalAmount),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Hủy'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
          onPressed: () async {
            try {
              final result = await _billService.updateBill(
                widget.token,
                widget.bill.id,
                {
                  'address': addressController.text,
                  'status_bill': selectedStatus.value,
                  'status_payment': selectedPayment.value,
                },
              );

              if (!mounted) return;

              Navigator.pop(context); // pop 1 lần duy nhất

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result ? 'Cập nhật thành công' : 'Cập nhật thất bại'),
                ),
              );

              if (result) {
                widget.onRefresh(); // chỉ refresh khi thành công
              }

            } catch (e) {
              if (!mounted) return;

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi: $e')),
              );
            }
          },
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            elevation: 3,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
            child: const Text(
            'Lưu thay đổi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          ),
        ),
      ],
    );
  }
}