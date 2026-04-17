import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:backend/core/config/config.dart';

class ResponseUtil {
  // Header JSON dùng chung

  /// 200 OK - success
  static Response success(
    dynamic data, {
    String message = 'Success',
  }) {
    return Response.ok(
      jsonEncode({
        'success': true,
        'message': message,
        'data': data,
      }),
      headers: headers,
    );
  }

  /// 400 Bad Request
  static Response badRequest(String message) {
    return Response(
      400,
      body: jsonEncode({
        'success': false,
        'error': message,
      }),
      headers: headers,
    );
  }

  /// 401 Unauthorized
  static Response unauthorized([String message = 'Unauthorized']) {
    return Response(
      401,
      body: jsonEncode({
        'success': false,
        'error': message,
      }),
      headers: headers,
    );
  }

  /// 403 Forbidden
  static Response forbidden([String message = 'Forbidden']) {
    return Response(
      403,
      body: jsonEncode({
        'success': false,
        'error': message,
      }),
      headers: headers,
    );
  }

  /// 404 Not Found
  static Response notFound(String message) {
    return Response(
      404,
      body: jsonEncode({
        'success': false,
        'error': message,
      }),
      headers: headers,
    );
  }

  /// 500 Internal Server Error
  static Response serverError([String message = 'Internal server error']) {
    return Response.internalServerError(
      body: jsonEncode({
        'success': false,
        'error': message,
      }),
      headers: headers,
    );
  }
}
