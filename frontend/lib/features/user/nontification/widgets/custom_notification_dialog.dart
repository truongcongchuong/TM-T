import 'package:flutter/material.dart';
import 'package:frontend/core/models/nontification.dart';
import 'package:frontend/core/enum/icon_color.dart';

class ModernNotificationDialog extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onConfirm;

  const ModernNotificationDialog({
    super.key,
    required this.notification,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive width
    final double dialogWidth = screenWidth > 1200
        ? 520
        : screenWidth > 800
            ? 480
            : screenWidth * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Center(
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 20),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ===== ICON VUÔNG =====
              Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  color: NotificationUIHelper
                      .getColor(notification.type)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  NotificationUIHelper.getIcon(notification.type),
                  size: 48,
                  color:
                      NotificationUIHelper.getColor(notification.type),
                ),
              ),

              const SizedBox(height: 24),

              /// ===== TITLE =====
              Text(
                notification.title ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              /// ===== BODY =====
              Text(
                notification.body ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              /// ===== PAYLOAD BOX =====
              if (notification.payload != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        "Mã đơn",
                        notification.payload?["id"]?.toString() ?? "",
                      ),
                      _infoRow(
                        "SĐT",
                        notification.payload?["phone_number"] ?? "",
                      ),
                      _infoRow(
                        "Địa chỉ",
                        notification.payload?["address"] ?? "",
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              /// ===== BUTTONS =====
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Đóng"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            NotificationUIHelper.getColor(notification.type),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: onConfirm,
                      child: const Text(
                        "Xác nhận",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}