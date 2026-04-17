import 'package:flutter/material.dart';
import 'package:frontend/core/models/cart.dart';
import 'package:frontend/core/models/payment_model.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/user/services/order_services.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/models/bill.dart';
import './widgets/edit_address.dart';
import './widgets/bill_preview_mobile_layout.dart';
import './widgets/bill_preview_web_layout.dart';
import 'package:frontend/core/enum/method_payment.dart';
class BillPreviewScreen extends StatefulWidget {
  final Cart cart;

  const BillPreviewScreen({super.key, required this.cart});

  @override
  State<BillPreviewScreen> createState() => _BillPreviewScreenState();
}

class _BillPreviewScreenState extends State<BillPreviewScreen> {
  late Bill bill;
  final OrderServices orderServices = OrderServices();
  late String? token;

  // === Biến chọn phương thức thanh toán ===
  MethodPayment selectedPaymentMethod = MethodPayment.cod; // mặc định là COD

  final List<MethodPayment> paymentMethods = [
    MethodPayment.cod,
    MethodPayment.banking,
    MethodPayment.momo,
    MethodPayment.vnPay,
    MethodPayment.zaloPay
  ];

  @override
  void initState() {
    super.initState();
 
    final user = context.read<AuthProvider>().user!;
    token = context.read<AuthProvider>().token;

    bill = Bill(
      userId: user.id!,
      phoneNumber: user.phoneNumber,
      address: user.defaultAddress,
      items: widget.cart.items
          .map(
            (item) => BillItem(
              foodId: item.food.id!,
              quantity: item.quantity,
            ),
          )
          .toList(),
    );
  }

  // ================= ACTIONS =================
  Future<void> onEditAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAddressScreen(
          address: bill.address,
          phone: bill.phoneNumber,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        bill = bill.copyWith(
          customerAddress: result['address'],
          phoneNumber: result['phone'],
        );
      });
    }
  }

  // Hàm xử lý khi thay đổi phương thức thanh toán
  void onPaymentMethodChanged(MethodPayment method) {
    setState(() {
      selectedPaymentMethod = method;
    });
  }

  // Hàm đặt hàng
  Future<void> onSubmit() async {
    // 👉 lấy methodId từ server
    final methodId = await orderServices.fetchPaymentMethods(selectedPaymentMethod);
    print("Selected payment method: $selectedPaymentMethod, methodId from server: $methodId");
    // 👉 tạo payment đúng
    final payment = PaymentModel(
      id: 0,
      billId: 0,
      methodId: methodId,
      statusId: 10, // ví dụ pending
    );

    // 👉 gắn vào bill nếu cần
    if (token == null) {
      return;
    }

    final success = await orderServices.order(token! , bill, payment);

    print(success);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đặt hàng thành công' : 'Đặt hàng thất bại',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để bắt đầu đặt hàng')),
      );
    }

    final total = widget.cart.items.fold<double>(
      0,
      (sum, item) => sum + item.food.price * item.quantity,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 255, 68, 54),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: width >= 1200 ? 1100 : width,
              ),
              child: width < 768
                  ? BillPreviewMobileLayout(
                      bill: bill,
                      onEditAddress: onEditAddress,
                      onSubmit: onSubmit,
                      total: total,
                      cart: widget.cart,
                      // Truyền thêm các tham số thanh toán
                      selectedPaymentMethod: selectedPaymentMethod,
                      paymentMethods: paymentMethods,
                      onPaymentMethodChanged: onPaymentMethodChanged,
                    )
                  : BillPreviewWebLayout(
                      bill: bill,
                      onEditAddress: onEditAddress,
                      onSubmit: onSubmit,
                      total: total,
                      cart: widget.cart,
                      // Truyền thêm các tham số thanh toán
                      selectedPaymentMethod: selectedPaymentMethod,
                      paymentMethods: paymentMethods,
                      onPaymentMethodChanged: onPaymentMethodChanged,
                    ),
            ),
          );
        },
      ),
    );
  }
}