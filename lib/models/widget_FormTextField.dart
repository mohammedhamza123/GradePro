import 'package:flutter/material.dart';

class FormTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool? readonly;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  const FormTextField(
      {super.key,
      required this.hint,
      required this.icon,
      this.validator,
      this.onChanged,
      this.controller,
      required this.isPassword,
      this.readonly});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: TextFormField(
        obscureText: isPassword,
        readOnly: readonly == null ? false : readonly!,
        decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hint,
            hintStyle: const TextStyle(fontWeight: FontWeight.bold),
            border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 3))),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
