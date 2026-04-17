import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:frontend/core/models/nontification.dart';

class SocketManager {
  late WebSocketChannel channel;

  final _notificationController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get notificationStream =>
      _notificationController.stream;

  Future<void> connectSocket(int userId) async {
    final uri = Uri.parse("ws://127.0.0.1:8080?userId=$userId");

    channel = WebSocketChannel.connect(uri);

    channel.stream.listen(
      (data) {
        final json = jsonDecode(data);
        print("RAW SOCKET DATA: $data");
        final notification = NotificationModel.fromMap(json);

        // Đẩy ra stream
        _notificationController.add(notification);
        print("connected server");
      },
      onDone: () {
        print("Disconnected");
      },
      onError: (e) {
        print("Socket error: $e");
      },
    );
  }

  void disconnect() {
    channel.sink.close();
    _notificationController.close();
  }
}