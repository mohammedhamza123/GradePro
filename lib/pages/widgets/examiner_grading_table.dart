import 'package:flutter/material.dart';
import 'examiner_grade_item.dart';

class ExaminerGradingTable extends StatelessWidget {
  final List<ExaminerGradeItem> examinerGradeItems;
  final int totalScore;
  final void Function() onScoreChanged;
  final bool shouldFocusEmpty;

  const ExaminerGradingTable({
    Key? key,
    required this.examinerGradeItems,
    required this.totalScore,
    required this.onScoreChanged,
    this.shouldFocusEmpty = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('البند',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('الدرجة القصوى',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('الدرجة',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('ملاحظات',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...examinerGradeItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              item.scoreController.addListener(() {
                final text = item.scoreController.text;
                if (text.isNotEmpty) {
                  final value = int.tryParse(text);
                  if (value != null && value > item.maxScore) {
                    item.scoreController.text = item.maxScore.toString();
                    item.scoreController.selection = TextSelection.fromPosition(TextPosition(offset: item.scoreController.text.length));
                  }
                }
              });
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.title, textAlign: TextAlign.right),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.maxScore.toString(),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: item.scoreController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'الدرجة',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      onChanged: (_) => onScoreChanged(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: item.noteController,
                      decoration: const InputDecoration(
                        hintText: 'ملاحظات',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('المجموع: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('$totalScore / 500',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
} 