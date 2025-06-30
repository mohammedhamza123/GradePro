import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/src/widgets/text_style.dart' as TextStylePanting;

import 'package:pdf/widgets.dart';

class GradingTablePdf extends pw.StatelessWidget {
  final List<String> header;
  final List<String> dataColumn1;
  final List<String> dataColumn2;
  final List<String> editableColumn1;
  final List<String> editableColumn2;
  final data;

  GradingTablePdf(
    this.header,
    this.dataColumn1,
    this.dataColumn2,
    this.editableColumn1,
    this.editableColumn2,
    this.data,
  );

  @override
  pw.Widget build(pw.Context context) {
    return pw.Directionality(
        child: pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    for (var i = header.length - 1; i >= 0; i--)
                      _buildHeaderCell(header[i]),
                  ],
                ),
                for (var i = 0; i < dataColumn1.length; i++)
                  pw.TableRow(
                    children: [
                      _buildStaticCell(dataColumn1[i]),
                      _buildStaticCell(dataColumn2[i]),
                      _buildStaticCell(editableColumn1[i]),
                      _buildStaticCell(editableColumn2[i]),
                    ].reversed.toList(),
                  ),
              ],
            ),
          ),
        ),
        textDirection: pw.TextDirection.rtl);
  }

  pw.Widget _buildHeaderCell(String text) {
    var myFont = Font.ttf(data);
    return pw.Container(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontSize: 16.0, fontWeight: pw.FontWeight.bold, font: myFont),
      ),
    );
  }

  pw.Widget _buildStaticCell(String text) {
    var myFont = Font.ttf(data);
    return pw.Container(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 16.0, font: myFont),
      ),
    );
  }
}
