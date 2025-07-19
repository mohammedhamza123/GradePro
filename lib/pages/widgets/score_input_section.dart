import 'package:flutter/material.dart';

class ScoreInputSection extends StatelessWidget {
  final bool isExaminer;
  final String examinerCollegeScore;
  final String coordinatorScore;
  final String headScore;
  final ValueChanged<String> onExaminerCollegeScoreChanged;
  final ValueChanged<String> onCoordinatorScoreChanged;
  final ValueChanged<String> onHeadScoreChanged;
  final double cardRadius;

  const ScoreInputSection({
    Key? key,
    required this.isExaminer,
    required this.examinerCollegeScore,
    required this.coordinatorScore,
    required this.headScore,
    required this.onExaminerCollegeScoreChanged,
    required this.onCoordinatorScoreChanged,
    required this.onHeadScoreChanged,
    required this.cardRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isExaminer) {
      return TextFormField(
        initialValue: examinerCollegeScore,
        onChanged: onExaminerCollegeScoreChanged,
        decoration: InputDecoration(
          labelText: 'درجة الكلية (من 25)',
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
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        keyboardType: TextInputType.number,
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: coordinatorScore,
              onChanged: onCoordinatorScoreChanged,
              decoration: InputDecoration(
                labelText: 'درجة منسق المشاريع (من 5)',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: headScore,
              onChanged: onHeadScoreChanged,
              decoration: InputDecoration(
                labelText: 'درجة رئيس القسم (من 5)',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      );
    }
  }
} 