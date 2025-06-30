import 'package:flutter/material.dart';

class AdminSearchbar extends StatelessWidget {
  final void Function(String)? onChanged;
  final TextEditingController editingController;
  final Icon? icon;

  const AdminSearchbar(
      {super.key,
      this.onChanged,
      required this.editingController,
      this.icon = const Icon(color: Colors.black, Icons.search, size: 32)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: TextField(
          controller: editingController,
          onChanged: onChanged,
          decoration:  InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0.0),
                borderRadius: BorderRadius.all(Radius.circular(32)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 0.0),
                borderRadius: BorderRadius.all(Radius.circular(32)),
              ),
              suffixIcon: icon),
        ),
      ),
    );
  }
}
