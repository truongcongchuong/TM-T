import 'dart:io';
import 'package:shelf/shelf.dart';

Handler staticImageHandler = (Request request) {
  final path = request.url.path; // images/burger.jpg
  final file = File('public/$path');

  if (!file.existsSync()) {
    return Response.notFound('Image not found');
  }

  return Response.ok(
    file.openRead(),
    headers: {
      'Content-Type': _getContentType(path),
    },
  );
};

String _getContentType(String path) {
  if (path.endsWith('.png')) return 'image/png';
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
  if (path.endsWith('.webp')) return 'image/webp';
  return 'application/octet-stream';
}
