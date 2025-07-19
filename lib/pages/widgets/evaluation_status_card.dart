import 'package:flutter/material.dart';

class EvaluationStatusCard extends StatelessWidget {
  final double? finalScore;
  final bool isComplete;
  final int evaluatorsCount;
  final double cardRadius;

  const EvaluationStatusCard({
    Key? key,
    required this.finalScore,
    required this.isComplete,
    required this.evaluatorsCount,
    required this.cardRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isComplete ? Colors.green[50] : Colors.orange[50],
        border: Border.all(
          color: isComplete ? Colors.green : Colors.orange,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة التقييم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isComplete ? Colors.green[800] : Colors.orange[800],
            ),
          ),
          const SizedBox(height: 8),
          Text('عدد المقيمين: $evaluatorsCount'),
          Text('اكتمال التقييم: ${isComplete ? "نعم" : "لا"}'),
          if (finalScore != null) ...[
            const SizedBox(height: 8),
            Text(
              'الدرجة النهائية: ${finalScore!.toStringAsFixed(2)} من 100',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'الدرجة النهائية: غير محسوبة بعد',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'الشرط: المشرف + ممتحنين اثنين على الأقل',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 