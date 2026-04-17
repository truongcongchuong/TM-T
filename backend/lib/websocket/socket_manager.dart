import 'dart:convert';
import 'dart:io';

class SocketManager {
  static final Map<int, WebSocket> userSockets = {};

  static void addUser(int id, WebSocket socket) {
    userSockets[id] = socket;
  }

  static void removeUser(int id) {
    userSockets.remove(id);
  }

  static void sendToUser(int userId, Map data) {
    userSockets[userId]?.add(jsonEncode(data));
  }
}
