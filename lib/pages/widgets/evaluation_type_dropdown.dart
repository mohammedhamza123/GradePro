import 'package:flutter/material.dart';

class EvaluationTypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const EvaluationTypeDropdown({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('نوع التقييم: '),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: value,
          items: ['جماعي', 'فردي']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
} 