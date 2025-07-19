import 'package:flutter/material.dart';

class EvaluationItem {
  final String detail;
  final int maxScore;
  EvaluationItem({required this.detail, required this.maxScore});
}

class EvaluationItemsList extends StatelessWidget {
  final List<EvaluationItem> items;
  final List<String> scores;
  final List<String> notes;
  final ValueChanged<int> onScoreChanged;
  final ValueChanged<int> onNoteChanged;
  final double cardRadius;

  const EvaluationItemsList({
    Key? key,
    required this.items,
    required this.scores,
    required this.notes,
    required this.onScoreChanged,
    required this.onNoteChanged,
    required this.cardRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: index % 2 == 0 ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item.detail),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item.maxScore.toString()),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: scores[index],
                    onChanged: (val) => onScoreChanged(index),
                    decoration: InputDecoration(
                      hintText: 'الدرجة',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: notes[index],
                    onChanged: (val) => onNoteChanged(index),
                    decoration: InputDecoration(
                      hintText: 'ملاحظات',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 