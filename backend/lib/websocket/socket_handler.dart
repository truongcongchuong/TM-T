import 'dart:io';
import "socket_manager.dart";
void handleSocket(WebSocket socket, int id) {

  print("Client connected with id: $id");
 
  SocketManager.addUser(id, socket);
  socket.listen(
    (data) {
      print("Received: $data");
    },
    onDone: () {
      print("Client disconnected");
    },
    onError: (error) {
      print("Socket error: $error");
    },
  );
}
