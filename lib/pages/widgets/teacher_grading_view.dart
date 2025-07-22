import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_provider.dart';
import 'grading_page.dart';

class TeacherGradingView extends StatelessWidget {
  const TeacherGradingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(builder: (context, provider, _) {
      // The logic to check for a current project remains the same.
      if (provider.currentProject != null) {
        // Before: return GradingTable(project: provider.currentProject);
        // After: Return the new GradingPage, which now contains all the logic.
        return GradingPage(project: provider.currentProject!);
      } else {
        return const Center(child: Text("لم يتم أختيار مشروع لعرض التقييم"));
      }
    });
  }
}