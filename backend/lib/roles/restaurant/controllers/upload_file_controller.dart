import '../../../core/config/config.dart';
import 'package:shelf/shelf.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../../core/utils/response.dart';
import 'package:backend/shared/services/upload_file_service.dart';
import 'package:backend/shared/enum/user_role_enum.dart';

class UploadFileController {
  final UploadFileService _uploadFileService = UploadFileService();

  Future<Response> uploadFileImageFood(Request req) async {
    try {
      final restaurantId = req.context['userId'] as int?;
      final role = req.context['role'] as String?;
      if (restaurantId == null || role != UserRoleEnum.restaurantOwner.value) {
        return ResponseUtil.unauthorized();
      }
      final contentTypeHeader = req.headers['content-type'];

      if (contentTypeHeader == null) {
        return Response.badRequest(body: 'Missing content-type header');
      }

      final contentType = MediaType.parse(contentTypeHeader);

      if (contentType.mimeType != 'multipart/form-data') {
        return Response.badRequest(body: 'Request must be multipart');
      }

      final boundary = contentType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(body: 'Missing boundary');
      }

      final transformer = MimeMultipartTransformer(boundary);
      final parts = await transformer.bind(req.read()).toList();

      for (final part in parts) {
        final headers = part.headers;

        final disposition = headers['content-disposition'];
        if (disposition == null) continue;

        if (!disposition.contains('name="image"')) continue;

        final fileNameMatch = RegExp(r'filename="(.+)"').firstMatch(disposition);
        final originalName = fileNameMatch?.group(1) ?? 'upload.jpg';

        // validate image
        final mimeType = lookupMimeType(originalName);
        if (mimeType == null || !mimeType.startsWith('image/')) {
          return Response.badRequest(body: 'Only images allowed');
        }

        final newName = await _uploadFileService.saveFile(part, originalName, uploadDirectory);

        return ResponseUtil.success({'fileName': newName}, message: 'File uploaded');
      }

      return Response.badRequest(body: 'No file found');
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }
}