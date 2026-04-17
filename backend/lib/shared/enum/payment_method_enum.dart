enum MethodPayment {
  cod('COD'),
  momo('Momo'),
  zaloPay('ZaloPay'),
  vnPay('VNPay'),
  banking('Banking');

  final String value;
  const MethodPayment(this.value);

  static  MethodPayment fromString(String methodPayment) {
    return MethodPayment.values.firstWhere(
      (e) => e.value == methodPayment,
      orElse: () => MethodPayment.cod,
    );
  }
}
