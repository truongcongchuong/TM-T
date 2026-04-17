import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../auth/jwt_service.dart';
import 'package:backend/core/config/config.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request req) async {
      final authHeader = req.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer')) {
        return Response(
          401,
          body: jsonEncode({'error': 'Unauthorized'}),
          headers: headers,
        );
      }

      final token = authHeader.substring(7);
      final jwt = JwtService.verifyToken(token);

      final userId = jwt.payload['userId'] as int;
      final role = jwt.payload['role'] as String;

      final updatedReq = req.change(context: {
        'userId': userId,
        'role': role,
      });

      return innerHandler(updatedReq);
    };
  };
}
