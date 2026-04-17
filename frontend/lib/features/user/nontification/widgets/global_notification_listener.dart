import 'dart:async';
import 'package:frontend/websocket/socket.dart';
import 'custom_notification_dialog.dart';
import 'package:frontend/main.dart'; // nơi khai báo navigatorKey
import 'package:flutter/material.dart';


class GlobalNotificationListener {
  static late SocketManager socketManager;
  static StreamSubscription? subscription;

  static void init(int userId) {
    socketManager = SocketManager();
    socketManager.connectSocket(userId);

    subscription =
    socketManager.notificationStream.listen((noti) {
      final context = navigatorKey.currentContext;
      if (context == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ModernNotificationDialog(
          notification: noti,
          onConfirm: () {
            Navigator.of(context).pop();

            // Xử lý sau
            print("Confirmed ${noti.id}");
          },
        ),
      );
    });
  }

  static void dispose() {
    subscription?.cancel();
    socketManager.disconnect();
  }
}