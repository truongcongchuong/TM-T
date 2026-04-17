enum MethodPayment {
  cod('COD', "Thanh toán khi nhận hàng"),
  momo('Momo', "Momo"),
  zaloPay('ZaloPay','ZaloPay'),
  vnPay('VNPay', 'VNPay'),
  banking('Banking', 'Thanh toán bằng chuyển khoản' );

  final String value;
  final String title;
  const MethodPayment(this.value, this.title);

  static  MethodPayment fromString(String methodPayment) {
    return MethodPayment.values.firstWhere(
      (e) => e.value == methodPayment,
      orElse: () => MethodPayment.cod,
    );
  }
}
