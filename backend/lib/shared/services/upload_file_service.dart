import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:math';

class UploadFileService {
  Future<String> saveFile(Stream<List<int>> fileStream, String originalName, String uploadDirectory) async {
    final ext = p.extension(originalName);
    final newName =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}$ext';
    
    final filePath = p.join(uploadDirectory, newName);
    final file = File(filePath);
    await file.create(recursive: true);

    final sink = file.openWrite();
    await fileStream.pipe(sink);
    await sink.close();

    return newName;
  }

  Future<void> deleteFile(String fileName, String uploadDirectory) async {
    final filePath = p.join(uploadDirectory, fileName);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}