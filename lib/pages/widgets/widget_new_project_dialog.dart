import 'package:flutter/material.dart';

class AddProjectDialog extends StatefulWidget {
  final Function(String) onSave;

  const AddProjectDialog({super.key, required this.onSave});

  @override
  _AddProjectDialogState createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('ادخل عنوان المشروع'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'العنوان',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('الغاء'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('حفظ المشروع'),
            onPressed: () {
              String title = _titleController.text;
              widget.onSave(title);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
