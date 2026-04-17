import 'package:flutter/material.dart';
import 'package:frontend/core/models/bill.dart';
import 'address_card.dart';
import 'product_section.dart';
import 'order_summary_card.dart';
import 'package:frontend/core/models/cart.dart';
import 'package:frontend/core/enum/method_payment.dart';

class BillPreviewWebLayout extends StatelessWidget {
  final Bill bill;
  final VoidCallback onEditAddress;
  final VoidCallback onSubmit;
  final double total;
  final Cart cart;

  // === Tham số mới cho phương thức thanh toán ===
  final MethodPayment selectedPaymentMethod;
  final  List<MethodPayment> paymentMethods;
  final Function(MethodPayment) onPaymentMethodChanged;

  const BillPreviewWebLayout({
    super.key,
    required this.bill,
    required this.onEditAddress,
    required this.onSubmit,
    required this.total,
    required this.cart,
    required this.selectedPaymentMethod,
    required this.paymentMethods,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột trái: Địa chỉ + Sản phẩm
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AddressCard(
                    bill: bill,
                    onTap: onEditAddress,
                  ),
                  const SizedBox(height: 16),
                  ProductSection(cart: cart),
                ],
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Cột phải: Tóm tắt đơn hàng + Phương thức thanh toán
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  OrderSummaryCard(
                    total: total,
                    onSubmit: onSubmit,
                  ),
                  const SizedBox(height: 20),

                  // ================= PHẦN CHỌN PHƯƠNG THỨC THANH TOÁN =================
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phương thức thanh toán',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ...paymentMethods.map((method) {
                            final isSelected = selectedPaymentMethod == method;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: RadioListTile<MethodPayment>(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                value: method,
                                groupValue: selectedPaymentMethod,
                                onChanged: (value) =>
                                    onPaymentMethodChanged(value!),
                                title: Text(method.title),
                                secondary: Icon(
                                  method == MethodPayment.cod
                                      ? Icons.delivery_dining_outlined
                                      : Icons.payment_outlined,
                                  color: isSelected ? Colors.orange : Colors.grey,
                                ),
                                activeColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}