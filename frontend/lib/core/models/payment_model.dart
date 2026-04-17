class PaymentModel {
  final int id;
  final int billId;
  final int methodId;
  final int statusId;
  final DateTime? paidAt;

  PaymentModel({
    required this.id,
    required this.billId,
    required this.methodId,
    required this.statusId,
    this.paidAt,
  });

  // ================= FROM MAP =================
  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'],
      billId: map['bill_id'],
      methodId: map['method_id'],
      statusId: map['status_id'],
      paidAt: map['paid_at'] != null
          ? DateTime.parse(map['paid_at'])
          : null,
    );
  }

  // ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "bill_id": billId,
      "method_id": methodId,
      "status_id": statusId,
      "paid_at": paidAt?.toIso8601String(),
    };
  }
}