import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/src/widgets/text_style.dart' as TextStylePanting;

import 'package:pdf/widgets.dart';
import '../../providers/pdf_provider.dart';

class GradingTablePdf extends pw.StatelessWidget {
  final List<EvaluationItem> evaluationItems;
  final List<String> scores;
  final List<String> notes;
  final String supervisorUsername;
  final String studentName;
  final String projectTitle;
  final String evaluationType; // جماعي أو فردي
  final arabicFontData;

  GradingTablePdf(
    this.evaluationItems,
    this.scores,
    this.notes,
    this.supervisorUsername,
    this.studentName,
    this.projectTitle,
    this.evaluationType,
    this.arabicFontData,
  );

  @override
  pw.Widget build(pw.Context context) {
    print('evaluationItems.length: \\${evaluationItems.length}');
    print('scores.length: \\${scores.length}');
    print('notes.length: \\${notes.length}');
    print('evaluationItems: \\${evaluationItems.map((e) => e.detail).toList()}');
    print('scores: \\${scores}');
    print('notes: \\${notes}');
    var arabicFont = pw.Font.ttf(arabicFontData);
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'نموذج تقييم النهائي من المشرف',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  font: arabicFont,
                ),
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('اسم المشروع: $projectTitle',
                  style: pw.TextStyle(fontSize: 16, font: arabicFont)),
                pw.Text('نوع التقييم: $evaluationType',
                  style: pw.TextStyle(fontSize: 16, font: arabicFont)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('اسم الطالب: $studentName',
                  style: pw.TextStyle(fontSize: 16, font: arabicFont)),
                pw.Text('المشرف: $supervisorUsername',
                  style: pw.TextStyle(fontSize: 16, font: arabicFont)),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    _buildHeaderCell('البند', arabicFont),
                    _buildHeaderCell('الدرجة الكاملة', arabicFont),
                    _buildHeaderCell('الدرجة', arabicFont),
                    _buildHeaderCell('الملاحظات', arabicFont),
                  ],
                ),
                for (var i = 0; i < evaluationItems.length; i++)
                  pw.TableRow(
                    children: [
                      _buildStaticCell(evaluationItems[i].detail, arabicFont),
                      _buildStaticCell(evaluationItems[i].maxScore.toString(), arabicFont),
                      _buildStaticCell((scores.length > i && scores[i].isNotEmpty) ? scores[i] : '-', arabicFont),
                      _buildStaticCell((notes.length > i && notes[i].isNotEmpty) ? notes[i] : '-', arabicFont),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildHeaderCell(String text, pw.Font arabicFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 16.0,
          fontWeight: pw.FontWeight.bold,
          font: arabicFont,
        ),
      ),
    );
  }

  pw.Widget _buildStaticCell(String text, pw.Font arabicFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 16.0,
          font: arabicFont,
        ),
      ),
    );
  }
}
