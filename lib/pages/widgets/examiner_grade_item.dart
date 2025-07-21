import 'package:flutter/material.dart';

class ExaminerGradeItem {
  final String title;
  final int maxScore;
  final TextEditingController scoreController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  ExaminerGradeItem(this.title, this.maxScore);
} 