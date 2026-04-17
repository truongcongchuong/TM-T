import 'package:shelf/shelf.dart';
import '../../../shared/services/notification_service.dart';
import '../../../core/utils/response.dart';

class UserNotificationController {
  final NotificationService notificationService = NotificationService();

  Future<Response> loadNotification(Request req) async {
    final userId = req.context['userId'] as int?;

    if (userId == null) {
      return Response.unauthorized("You need Login");
    }

    final notifications = await notificationService.loadNotification(userId);
    return ResponseUtil.success(
      notifications.map((n) => n.toMap()).toList(),
    );
  }
}
