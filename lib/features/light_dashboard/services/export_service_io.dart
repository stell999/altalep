import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ExportService {
  Future<String?> exportCsv(String filename, String content) async {
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content, flush: true);
    return file.path;
  }
}
