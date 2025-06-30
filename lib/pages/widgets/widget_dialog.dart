import 'package:flutter/material.dart';
import 'package:gradpro/models/requirement_list.dart';

class RequirementEditDialog extends StatefulWidget {
  final Function(Requirement) onDonePressed;

  const RequirementEditDialog({super.key, required this.onDonePressed});

  @override
  _RequirementEditDialogState createState() => _RequirementEditDialogState();
}

class _RequirementEditDialogState extends State<RequirementEditDialog> {
  late TextEditingController _textEditingController;
  late bool _status;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _status = false;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text("أضف متطلب جديد"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(hintText: 'محتوي المتطلب'),
              onSubmitted: (value) {
                String value = _textEditingController.text;
                String status = "i";
                if (_status) {
                  status = "c";
                }
                final Requirement requirement = Requirement(
                    name: value, suggestion: 0, id: 0, status: status);
                widget.onDonePressed(
                    requirement); // Call the function when Done is pressed
              },
            ),
            Row(
              children: [
                const Text("أنجز"),
                Checkbox(
                    value: _status,
                    onChanged: (val) {
                      if (val != null) {
                        _status = val;
                      } else {
                        _status = false;
                      }
                      setState(() {});
                    }),
                const Text("لم يتم"),
                Checkbox(
                    value: !_status,
                    onChanged: (val) {
                      if (val != null) {
                        _status = !val;
                      }
                      setState(() {});
                    }),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('حفظ'),
            onPressed: () {
              String value = _textEditingController.text;
              String status = "i";
              if (_status) {
                status = "c";
              }
              final Requirement requirement = Requirement(
                  name: value, suggestion: 0, id: 0, status: status);
              widget.onDonePressed(
                  requirement); // Call the function when Done is pressed
            },
          ),
        ],
      ),
    );
  }
}

class RequirementDialog extends StatefulWidget {
  final Function(String) onDonePressed;

  const RequirementDialog({super.key, required this.onDonePressed});

  @override
  _RequirementDialogState createState() => _RequirementDialogState();
}

class _RequirementDialogState extends State<RequirementDialog> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("أضف متطلب جديد"),
      content: TextField(
        controller: _textEditingController,
        decoration: const InputDecoration(hintText: 'محتوي المتطلب'),
        onSubmitted: (value) {
          widget.onDonePressed(value); // Call the function when Done is pressed
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('إلغاء'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('حفظ'),
          onPressed: () {
            String value = _textEditingController.text;
            widget
                .onDonePressed(value); // Call the function when Done is pressed
          },
        ),
      ],
    );
  }
}

class LoginErrorDialog extends StatelessWidget {
  final String errorMessage;

  const LoginErrorDialog({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('خطأ في تسجيل الدخول'),
      content: Text(errorMessage),
      actions: [
        TextButton(
          child: const Text('حسناً'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class SaveConfirmationDialog extends StatelessWidget {
  final VoidCallback onPress;

  const SaveConfirmationDialog({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حفظ الاقتراح'),
      content: const Text('هل أنت متأكد أنك تريد الحفظ؟'),
      actions: [
        TextButton(
          child: const Text('نعم'),
          onPressed: () {
            onPress();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('لا'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class PendingApprovalDialog extends StatelessWidget {
  final String username;

  const PendingApprovalDialog({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pending_actions,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'حسابك قيد المراجعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff00577B),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مرحباً بك في Gradify!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff00577B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'تم استلام طلب تسجيلك بنجاح',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'حسابك قيد المراجعة من قبل الإدارة. سيتم إعلامك عند الموافقة على طلبك.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'يمكنك:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff00577B),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'محاولة تسجيل الدخول لاحقاً للتحقق من حالة طلبك',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'التواصل مع الإدارة للمساعدة',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'حسناً',
              style: TextStyle(
                color: Color(0xff00577B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
