import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/device.dart';
import '../models/device_input.dart';

class DeviceLabelService {
  Future<void> printDeviceLabel(Device device) async {
    final regularFont = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          60 * PdfPageFormat.mm,
          40 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.all(3),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.8),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _valueLine(
                    device.customerName,
                    boldFont,
                    fallback: 'بدون اسم',
                  ),
                  pw.SizedBox(height: 4),
                  _valueLine(
                    _costLine(device),
                    regularFont,
                    fallback: '-',
                  ),
                  pw.SizedBox(height: 4),
                  _valueLine(
                    device.issue,
                    regularFont,
                    fallback: '-',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'device-label-${device.id}',
      onLayout: (PdfPageFormat format) async {
        final bytes = await document.save();
        return Uint8List.fromList(bytes);
      },
    );
  }

  Future<void> printReceiptFromInput({
    required DeviceInput input,
    required String userNote,
    PdfPageFormat? pageFormat,
  }) async {
    final regularFont = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    final now = DateTime.now();
    final date = _formatDate(now);

    final format = pageFormat ??
        const PdfPageFormat(
          80 * PdfPageFormat.mm,
          120 * PdfPageFormat.mm,
        );

    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(6),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _labeledLine('اسم الزبون', input.customerName, boldFont),
                pw.SizedBox(height: 4),
                _labeledLine('اسم الجهاز', input.deviceName, regularFont),
                pw.SizedBox(height: 4),
                _labeledLine('تاريخ الاستلام', date, regularFont),
                pw.SizedBox(height: 4),
                _labeledLine('التكلفة', _costLineFromInput(input), regularFont),
                pw.SizedBox(height: 4),
                _labeledLine('العطل', input.issue, regularFont),
                pw.SizedBox(height: 6),
                _labeledLine('ملاحظة', userNote, regularFont),
                pw.Spacer(),
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'شكراً لزيارتكم',
                    style: pw.TextStyle(font: regularFont, fontSize: 9),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'device-receipt-${date}',
      onLayout: (PdfPageFormat format) async {
        final bytes = await document.save();
        return Uint8List.fromList(bytes);
      },
    );
  }

  Future<void> printLabelFromInput({
    required DeviceInput input,
    PdfPageFormat? pageFormat,
    String? userNote,
  }) async {
    final regularFont = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    final format = pageFormat ??
        const PdfPageFormat(
          60 * PdfPageFormat.mm,
          40 * PdfPageFormat.mm,
        );

    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(3),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.8),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _valueLine(input.customerName, boldFont, fallback: 'بدون اسم'),
                  pw.SizedBox(height: 4),
                  _valueLine(_costLineFromInput(input), regularFont, fallback: '-'),
                  pw.SizedBox(height: 4),
                  _valueLine(input.issue, regularFont, fallback: '-'),
                  if (userNote != null && userNote.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    _valueLine(userNote, regularFont, fallback: '-'),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'device-label-${input.deviceName}',
      onLayout: (PdfPageFormat format) async {
        final bytes = await document.save();
        return Uint8List.fromList(bytes);
      },
      format: format,
    );
  }

  Future<void> printCompactLabel40x20FromInput({
    required DeviceInput input,
    required String userNote,
  }) async {
    final regularFont = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();
    final now = DateTime.now();
    final date = _formatDate(now);

    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          40 * PdfPageFormat.mm,
          20 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.all(2),
        build: (context) {
          final lines = <String>[
            input.customerName,
            _costLineFromInput(input),
            input.issue,
            date,
            if (userNote.trim().isNotEmpty) userNote.trim(),
          ].where((e) => e.trim().isNotEmpty && e.trim() != '-').toList();

          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Center(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < lines.length; i++)
                    pw.Text(
                      lines[i],
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: i == 0 ? boldFont : regularFont,
                        fontSize: 7.5,
                      ),
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'device-compact-40x20-${input.deviceName}',
      onLayout: (PdfPageFormat format) async {
        final bytes = await document.save();
        return Uint8List.fromList(bytes);
      },
      format: const PdfPageFormat(
        40 * PdfPageFormat.mm,
        20 * PdfPageFormat.mm,
      ),
    );
  }

  pw.Widget _valueLine(
    String value,
    pw.Font font, {
    required String fallback,
  }) {
    final displayValue = value.trim().isEmpty ? fallback : value.trim();
    return pw.Text(
      displayValue,
      style: pw.TextStyle(font: font, fontSize: 9),
      maxLines: 1,
      overflow: pw.TextOverflow.clip,
    );
  }

  String _costLine(Device device) {
    if (device.cost.trim().isEmpty) return '-';
    final currency = device.costCurrency.trim();
    if (currency.isEmpty) return device.cost.trim();
    return '${device.cost.trim()} $currency';
  }

  String _costLineFromInput(DeviceInput input) {
    if (input.cost.trim().isEmpty) return '-';
    final currency = input.costCurrency.trim();
    if (currency.isEmpty) return input.cost.trim();
    return '${input.cost.trim()} $currency';
  }

  pw.Widget _labeledLine(String label, String value, pw.Font font) {
    final displayValue = value.trim().isEmpty ? '-' : value.trim();
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            displayValue,
            style: pw.TextStyle(font: font, fontSize: 10),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> printCompactLabel40x20({
    required Device device,
    required String userNote,
  }) async {
    final regularFont = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();
    final now = DateTime.now();
    final date = _formatDate(now);

    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          40 * PdfPageFormat.mm,
          20 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.all(2),
        build: (context) {
          final lines = <String>[
            device.customerName,
            _costLine(device),
            device.issue,
            date,
            if (userNote.trim().isNotEmpty) userNote.trim(),
          ].where((e) => e.trim().isNotEmpty && e.trim() != '-').toList();

          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Center(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < lines.length; i++)
                    pw.Text(
                      lines[i],
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: i == 0 ? boldFont : regularFont,
                        fontSize: 7.5,
                      ),
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'device-compact-40x20-${device.id}',
      onLayout: (PdfPageFormat format) async {
        final bytes = await document.save();
        return Uint8List.fromList(bytes);
      },
    );
  }
}
