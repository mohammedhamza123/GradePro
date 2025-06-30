import 'package:flutter/material.dart';

class RequirementWidget extends StatelessWidget {
  final String title;
  final String status;
  final void Function() onDelete;
  final void Function() onEdit;

  const RequirementWidget({super.key, required this.title, required this.onDelete, required this.onEdit, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            status == 'i' ? const Icon(Icons.cancel_outlined):const Icon(Icons.done),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
          ],
        ),
      ),
    );
  }
}
