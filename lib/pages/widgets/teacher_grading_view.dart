import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_provider.dart';
import 'grading_table.dart';

class TeacherGradingView extends StatelessWidget {
  const TeacherGradingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(builder: (context, provider, _) {
      return provider.currentProject != null
          ? GradingTable(project: provider.currentProject)
          : const Center(child: Text("لم يتم أختيار مشروع لعرض التقييم"));
    });
  }
} 