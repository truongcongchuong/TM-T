import 'package:shelf/shelf.dart';
import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:backend/websocket/socket_handler.dart';

import 'package:backend/routes/routes.dart';
import 'package:backend/core/config/setup_database.dart';
import 'package:backend/shared/services/access_image.dart';
import 'package:backend/core/config/config.dart';
import 'package:backend/core/config/database.dart';

void main() async {
  try {
    await DatabaseConfig.init();
    await setupDatabase();
    print('Database ready');
  } catch (e) {
    print('DB setup failed: $e');
    return;
  }

  Middleware corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers':
                'Origin, Content-Type, Authorization',
          });
        }

        final response = await innerHandler(request);
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers':
              'Origin, Content-Type, Authorization',
        });
      };
    };
  }

  final shelfHandler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(
        Cascade()
            .add(staticImageHandler)
            .add(buildRouter().call)
            .handler,
      );

  final server = await HttpServer.bind(host, port);

  await for (HttpRequest request in server) {

  // Nếu là websocket request
  if (WebSocketTransformer.isUpgradeRequest(request)) {

    final userId = request.uri.queryParameters['userId'];

    // TODO: verify token ở đây
    if (userId == null) {
      request.response.statusCode = HttpStatus.unauthorized;
      await request.response.close();
      continue;
    }

    final socket = await WebSocketTransformer.upgrade(request);

    handleSocket(socket, int.parse(userId));

    } else {
      // Nếu không phải websocket thì chuyển cho shelf
      shelf_io.handleRequest(request, shelfHandler);
    }
  }

  print('Server running at http://${server.address}:${server.port}');
}
