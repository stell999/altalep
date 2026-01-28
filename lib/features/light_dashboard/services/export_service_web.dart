// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class ExportService {
  Future<String?> exportCsv(String filename, String content) async {
    final blob = html.Blob([content], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = filename
      ..click();
    html.Url.revokeObjectUrl(url);
    return 'download';
  }
}
