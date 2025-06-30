import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final Function onConfirm;

  const DeleteConfirmationDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: const Text('هل أنت متأكد من أنك تريد القيام بالحذف'),
      actions: <Widget>[
        TextButton(
          child: const Text('الغاء'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          child: const Text('تأكيد'),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}
