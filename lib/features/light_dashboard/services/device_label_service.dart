import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/device.dart';

class DeviceLabelService {
  Future<void> printDeviceLabel(Device device) async {
    final regularFont = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm,
          60 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.all(4),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1.2),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    'تفاصيل ${device.deviceName}',
                    style: pw.TextStyle(font: boldFont, fontSize: 12),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 6),
                  pw.Table(
                    columnWidths: const {
                      0: pw.FlexColumnWidth(1.1),
                      1: pw.FlexColumnWidth(1.2),
                    },
                    border: pw.TableBorder.symmetric(
                      inside: pw.BorderSide(
                        color: PdfColors.grey500,
                        width: 0.2,
                      ),
                    ),
                    children: [
                      _row(
                        'اسم الزبون',
                        device.customerName,
                        boldFont,
                        regularFont,
                      ),
                      _row('القسم', device.department, boldFont, regularFont),
                      _row('الحالة', device.status, boldFont, regularFont),
                      _row('العطل', device.issue, boldFont, regularFont),
                      _row(
                        'التكلفة',
                        device.cost.isEmpty ? '-' : device.cost,
                        boldFont,
                        regularFont,
                      ),
                    ],
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

  pw.TableRow _row(String label, String value, pw.Font bold, pw.Font regular) {
    final displayValue = value.isEmpty ? '-' : value;
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Text(label, style: pw.TextStyle(font: bold, fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              displayValue,
              style: pw.TextStyle(font: regular, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
