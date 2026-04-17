import 'package:backend/core/config/database.dart';
import 'package:backend/shared/enum/notification_type_enum.dart';
import 'package:backend/shared/models/notification_model.dart';
import 'package:postgres/postgres.dart';
import 'package:backend/websocket/socket_manager.dart';

class NotificationService {
  Future<bool> createNotification(NotificationModel notifi) async {
    final Connection conn = await DatabaseConfig.connection();

    try {
      // Lấy type_id từ code
      final typeResult = await conn.execute(
        Sql.named('''
        SELECT id FROM notification_types
        WHERE code = @code AND is_active = true
        LIMIT 1
        '''),
        parameters: {'code': notifi.type.code},
      );

      if (typeResult.isEmpty) {
        throw Exception('Notification type not found');
      }

      final typeId = typeResult.first[0] as int;

      // Insert notification
      final notifiId = await conn.execute(
        Sql.named('''
          INSERT INTO notifications
          (user_id, type_id, title, body, payload)
          VALUES (@userId, @typeId, @title, @body, @payload)
          RETURNING id;
        '''),
        parameters: {
          'userId': notifi.userId,
          'typeId': typeId,
          'title': notifi.title,
          'body': notifi.body,
          'payload': notifi.payload
        },
      );

      final id = notifiId.first[0] as int;

      final result = notifi.copyWith(id: id);

      SocketManager.sendToUser(
        result.userId,
        result.toMap()
      );
      return true;

    } catch (e) {
      print("lỗi tạo thông báo: $e");
      return false;
    } finally {
    }
  }

  // ======================= load thông báo ========================

  Future<List<NotificationModel>> loadNotification(int userId) async {
    try {
      final Connection conn = await DatabaseConfig.connection();
      final result = await conn.execute(
        Sql.named('''
          SELECT 
          n.id,
          n.user_id,
          n.title,
          n.body,
          n.payload,
          n.is_read,
          n.created_at,
          nt.code AS type

          FROM notifications n
          INNER JOIN notification_types nt ON n.type_id = nt.id

          WHERE n.user_id = @uId
          ORDER BY n.created_at DESC

          LIMIT 50
        '''),
        parameters: {"uId": userId},
      );
      
      conn.close();

      return result.map((row) => NotificationModel.fromRow(row)).toList();

    } catch (e) {
      print("lỗi load thông báo: $e");
      return [];
    }
  }
}
