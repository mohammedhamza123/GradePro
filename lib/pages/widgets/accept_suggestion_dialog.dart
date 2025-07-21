import 'package:flutter/material.dart';
import 'suggestion_styles.dart';

class AcceptSuggestionDialog extends StatelessWidget {
  const AcceptSuggestionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 30),
          const SizedBox(width: 10),
          const Text('الموافقة علي مقترح', style: kTitleTextStyle),
        ],
      ),
      content: const Text(''),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius)),
      actions: [
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context, 'Done');
            },
            icon: const Icon(Icons.done, color: Colors.green),
            label: const Text('Done', style: TextStyle(color: Colors.green)),
          ),
        ),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context, 'Reject');
            },
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context, 'Wait');
            },
            icon: const Icon(Icons.access_time, color: Colors.orange),
            label: const Text('Wait', style: TextStyle(color: Colors.orange)),
          ),
        ),
      ],
    );
  }
}
