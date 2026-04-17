import 'package:flutter/material.dart';
import 'package:frontend/core/models/bill.dart';
import 'address_card.dart';
import 'bottom_bar.dart';
import 'product_section.dart';
import 'package:frontend/core/models/cart.dart';
import 'package:frontend/core/enum/method_payment.dart';

class BillPreviewMobileLayout extends StatelessWidget {
  final Bill bill;
  final VoidCallback onEditAddress;
  final VoidCallback onSubmit;
  final double total;
  final Cart cart;

  // ✅ dùng enum
  final MethodPayment selectedPaymentMethod;
  final List<MethodPayment> paymentMethods;
  final Function(MethodPayment) onPaymentMethodChanged;

  const BillPreviewMobileLayout({
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AddressCard(
                  bill: bill,
                  onTap: onEditAddress,
                ),
                const SizedBox(height: 16),

                ProductSection(cart: cart),
                const SizedBox(height: 24),

                const Text(
                  'Phương thức thanh toán',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // ✅ map đúng
                ...paymentMethods.map((method) {
                  final isSelected = selectedPaymentMethod == method;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected ? Colors.orange : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RadioListTile<MethodPayment>(
                      value: method,
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        if (value != null) {
                          onPaymentMethodChanged(value);
                        }
                      },
                      title: Text(
                        method.title, // hiển thị text
                        style: const TextStyle(fontSize: 16),
                      ),
                      secondary: Icon(
                        method == MethodPayment.cod
                            ? Icons.delivery_dining_outlined
                            : Icons.account_balance_wallet_outlined,
                        color: isSelected ? Colors.orange : Colors.grey,
                      ),
                      activeColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        BillBottomBar(
          total: total,
          onSubmit: onSubmit,
        ),
      ],
    );
  }
}