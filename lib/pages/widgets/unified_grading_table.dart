import 'package:flutter/material.dart';
import '../../providers/pdf_provider.dart';

class UnifiedGradingTable extends StatefulWidget {
  final PdfProvider provider;
  final int totalScore;
  final void Function(int index, String value) onScoreChanged;
  final void Function(int index, String value) onNoteChanged;
  final bool shouldFocusEmpty;

  const UnifiedGradingTable({
    Key? key,
    required this.provider,
    required this.totalScore,
    required this.onScoreChanged,
    required this.onNoteChanged,
    this.shouldFocusEmpty = false,
  }) : super(key: key);

  @override
  State<UnifiedGradingTable> createState() => _UnifiedGradingTableState();
}

class _UnifiedGradingTableState extends State<UnifiedGradingTable> {
  late List<TextEditingController> _scoreControllers;
  late List<FocusNode> _scoreFocusNodes;

  @override
  void initState() {
    super.initState();
    _scoreControllers = List.generate(
      widget.provider.currentEvaluationItems.length,
      (i) => TextEditingController(text: widget.provider.scores[i]),
    );
    _scoreFocusNodes = List.generate(
      widget.provider.currentEvaluationItems.length,
      (i) => FocusNode(),
    );
    for (int i = 0; i < _scoreControllers.length; i++) {
      _scoreControllers[i].addListener(() {
        final text = _scoreControllers[i].text;
        if (text.isNotEmpty) {
          final value = int.tryParse(text);
          final max = widget.provider.currentEvaluationItems[i].maxScore;
          if (value != null && value > max) {
            _scoreControllers[i].text = max.toString();
            _scoreControllers[i].selection = TextSelection.fromPosition(TextPosition(offset: _scoreControllers[i].text.length));
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _scoreControllers) {
      c.dispose();
    }
    for (final f in _scoreFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

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
            ...widget.provider.currentEvaluationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.detail, textAlign: TextAlign.right),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.maxScore.toString(),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _scoreControllers[index],
                      focusNode: _scoreFocusNodes[index],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'الدرجة',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (val) => widget.onScoreChanged(index, val),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: widget.provider.notes[index],
                      onChanged: (val) => widget.onNoteChanged(index, val),
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
            Text('${widget.totalScore} / 500',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
} 