import 'package:flutter/material.dart';
import '../../models/student_details_list.dart';

class StudentDropdown extends StatelessWidget {
  final StudentDetail? selectedStudent;
  final List<StudentDetail> students;
  final bool isLoading;
  final ValueChanged<StudentDetail?> onChanged;
  final double cardRadius;

  const StudentDropdown({
    Key? key,
    required this.selectedStudent,
    required this.students,
    required this.isLoading,
    required this.onChanged,
    required this.cardRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return DropdownButtonFormField<StudentDetail>(
      value: selectedStudent,
      items: students
          .map((student) => DropdownMenuItem<StudentDetail>(
                value: student,
                child: Text(
                  '${student.user.firstName} ${student.user.lastName}',
                  // style: kBodyTextStyle, // Use your style if needed
                ),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'اسم الطالب',
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
    );
  }
} 