import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../models/project_details_list.dart';
import '../../models/student_details_list.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/pdf_provider.dart';
import 'suggestion_styles.dart';
import 'unified_grading_table.dart';
import 'examiner_grading_table.dart';
import 'examiner_grade_item.dart';

class GradingTable extends StatefulWidget {
  final ProjectDetail? project;
  const GradingTable({super.key, this.project});
  @override
  State<GradingTable> createState() => _GradingTableState();
}

class _GradingTableState extends State<GradingTable> {
  final TextEditingController projectTitleController = TextEditingController();
  String evaluationType = 'جماعي';
  StudentDetail? selectedStudent;
  List<StudentDetail> projectStudents = [];
  bool isLoadingStudents = true;

  // Examiner grading state
  final List<ExaminerGradeItem> examinerGradeItems = [
    // العرض والسمنار
    ExaminerGradeItem('الالتزام بمواعيد الإنجاز', 20),
    ExaminerGradeItem('المساهمة والمشاركة والتفاعل', 20),
    ExaminerGradeItem('مهارات الإلقاء', 30),
    ExaminerGradeItem('الوضوح والتسلسل المنطقي', 30),
    ExaminerGradeItem('استخدام الأدوات', 20),
    ExaminerGradeItem('الإجابة على الأسئلة', 30),
    // فهم المشروع
    ExaminerGradeItem('المشكلة المراد حلها', 20),
    ExaminerGradeItem('الادبيات السابقة و دراسة الحالة', 20),
    ExaminerGradeItem('مجال وحدود المشروع', 20),
    ExaminerGradeItem('الأهداف والمزايا والفوائد', 20),
    ExaminerGradeItem('الأسلوب (Methodology)', 20),
    // تصميم المشروع
    ExaminerGradeItem('التصميم الهيكلي (Architecture)', 30),
    ExaminerGradeItem('تصميم الواجهات (Interfaces)', 30),
    ExaminerGradeItem('تصميم قواعد البيانات (Persistence)', 30),
    ExaminerGradeItem('تصميم الخوارزميات (Algorithms)', 30),
    ExaminerGradeItem('الأمن الامان (Safety & Security)', 30),
    // التقرير
    ExaminerGradeItem('الشكل', 20),
    ExaminerGradeItem('الكمال', 20),
    ExaminerGradeItem('الجودة', 20),
    ExaminerGradeItem('استخدام الجيد للأدوات', 20),
    ExaminerGradeItem('اللغة العربية', 20),
  ];

  // Add refresh method
  Future<void> _refreshGradingStatus() async {
    final teacherProvider = context.read<TeacherProvider>();
    if (widget.project != null) {
      setState(() {
        isLoadingStudents = true;
      });
      try {
        final students = await teacherProvider
            .loadFilteredStudentForProject(widget.project!.id);
        setState(() {
          projectStudents = students;
          if (students.isNotEmpty) selectedStudent = students.first;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحديث قائمة الطلاب: $e')),
        );
      } finally {
        setState(() {
          isLoadingStudents = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      projectTitleController.text = widget.project!.title;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final teacherProvider = context.read<TeacherProvider>();
        final students = await teacherProvider
            .loadFilteredStudentForProject(widget.project!.id);
        setState(() {
          projectStudents = students;
          if (students.isNotEmpty) selectedStudent = students.first;
          isLoadingStudents = false;
        });
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final pdfProvider = context.read<PdfProvider>();
      pdfProvider.setIsExaminer(userProvider.isCurrentUserExaminer);
    });
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.read<TeacherProvider>();
    final project = widget.project;
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      final isExaminer = provider.isExaminer;
      final isSupervisor =
          widget.project?.teacher?.id == teacherProvider.teacher?.id;
      if (isSupervisor) {
        if (project?.supervisorScore != null) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(kCardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم التقييم بالفعل',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'درجة المشرف: ${project!.supervisorRaw?.toStringAsFixed(2) ?? "-"} من 40'),
                ],
              ),
            ),
          );
        }
        // Unified grading table UI for supervisor (teacher)
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          child: RefreshIndicator(
            onRefresh: _refreshGradingStatus,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    isLoadingStudents
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<StudentDetail>(
                            value: selectedStudent,
                            items: projectStudents
                                .map((student) =>
                                    DropdownMenuItem<StudentDetail>(
                                      value: student,
                                      child: Text(
                                        '${student.user.firstName} ${student.user.lastName}',
                                        style: kBodyTextStyle,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedStudent = val;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'اسم الطالب',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(kCardRadius),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(kCardRadius),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 20),
                            ),
                          ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: projectTitleController,
                      decoration: InputDecoration(
                        labelText: 'اسم المشروع',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kCardRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kCardRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('نوع التقييم: ', style: kBodyTextStyle),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: evaluationType,
                          items: ['جماعي', 'فردي']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => evaluationType = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Supervisor-specific fields (outside the table)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: provider.coordinatorScore,
                            onChanged: (val) =>
                                provider.setCoordinatorScore(val),
                            decoration: InputDecoration(
                              labelText: 'درجة منسق المشاريع (من 5)',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(kCardRadius),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(kCardRadius),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 20),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: provider.headScore,
                            onChanged: (val) => provider.setHeadScore(val),
                            decoration: InputDecoration(
                              labelText: 'درجة رئيس القسم (من 5)',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(kCardRadius),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(kCardRadius),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 20),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Unified grading table
                    UnifiedGradingTable(
                      provider: provider,
                      totalScore: provider.currentEvaluationItems
                          .asMap()
                          .entries
                          .fold(
                              0,
                              (sum, entry) =>
                                  sum +
                                  (int.tryParse(provider.scores[entry.key]) ??
                                      0)),
                      onScoreChanged: (index, val) =>
                          provider.setScore(index, val),
                      onNoteChanged: (index, val) =>
                          provider.setNote(index, val),
                      shouldFocusEmpty: true,
                    ),
                    const SizedBox(height: 20),
                    Consumer<TeacherProvider>(
                      builder: (context, teacherProvider, _) {
                        if (teacherProvider.currentProject != null) {
                          final project = teacherProvider.currentProject!;
                          final finalScore = project.calculatedFinalScore;
                          final isComplete = project.isEvaluationComplete;
                          final evaluatorsCount = project.numberOfEvaluators;
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: isComplete
                                  ? Colors.green[50]
                                  : Colors.orange[50],
                              border: Border.all(
                                color:
                                    isComplete ? Colors.green : Colors.orange,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(kCardRadius),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'حالة التقييم',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isComplete
                                        ? Colors.green[800]
                                        : Colors.orange[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('عدد المقيمين: $evaluatorsCount'),
                                Text(
                                    'اكتمال التقييم: ${isComplete ? "نعم" : "لا"}'),
                                if (finalScore != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'الدرجة النهائية: ${finalScore.toStringAsFixed(2)} من 100',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'الدرجة النهائية: غير محسوبة بعد',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  'الشرط: المشرف + ممتحنين اثنين على الأقل',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: !provider.isFileLoading
                            ? ElevatedButton(
                                onPressed: () async {
                                  final teacherProvider =
                                      context.read<TeacherProvider?>();

                                   ProjectDetail? project;
                                  int? teacherId;
                                  if (teacherProvider != null &&
                                      teacherProvider.currentProject != null) {
                                    project = teacherProvider.currentProject;
                                  }
                                  if (teacherProvider != null &&
                                      teacherProvider.teacher != null) {
                                    teacherId = teacherProvider.teacher!.id;
                                  }
                                  String supervisorUsername = "${project?.teacher?.user.firstName} ${project?.teacher?.user.lastName}";
                                  String projectTitle =
                                      projectTitleController.text;
                                  final evalType = evaluationType;
                                  String? pdfUrl;
                                  if (project != null && teacherId != null) {
                                    if (project.teacher?.id == teacherId) {
                                      provider.setIsExaminer(false);
                                      double supervisorRaw = provider.scores
                                          .fold(
                                              0,
                                              (prev, s) =>
                                                  prev + (int.tryParse(s) ?? 0))
                                          .toDouble();
                                      double headScore =
                                          double.tryParse(provider.headScore) ??
                                              0;
                                      double coordinatorScore = double.tryParse(
                                              provider.coordinatorScore) ??
                                          0;
                                      List<String> allStudentNames = projectStudents
                                          .map((s) =>
                                              '${s.user.firstName} ${s.user.lastName}')
                                          .toList();
                                      pdfUrl = await provider
                                          .uploadSupervisorPdfAndScores(
                                        pdfBytes: await provider.generatePdf(
                                          supervisorUsername:
                                              supervisorUsername,
                                          studentNames: allStudentNames,
                                          projectTitle: projectTitle,
                                          evaluationType: evalType,
                                          scores: provider.scores,
                                          notes: provider.notes,
                                        ),
                                        supervisorRaw: supervisorRaw,
                                        headScore: headScore,
                                        coordinatorScore: coordinatorScore,
                                        project: project,
                                      );
                                    } else if (project.examiner1Raw == null) {
                                      provider.setIsExaminer(true);
                                      double rawScore = provider.scores
                                          .fold(
                                              0,
                                              (prev, s) =>
                                                  prev + (int.tryParse(s) ?? 0))
                                          .toDouble();
                                      List<String> allStudentNames = projectStudents
                                          .map((s) =>
                                              '${s.user.firstName} ${s.user.lastName}')
                                          .toList();
                                      pdfUrl = await provider
                                          .uploadExaminer1PdfAndScore(
                                        pdfBytes: await provider.generatePdf(
                                          supervisorUsername:
                                              supervisorUsername,
                                          studentNames: allStudentNames,
                                          projectTitle: projectTitle,
                                          evaluationType: evalType,
                                          scores: provider.scores,
                                          notes: provider.notes,
                                        ),
                                        rawScore: rawScore,
                                        project: project,
                                      );
                                    } else if (project.examiner2Raw == null) {
                                      provider.setIsExaminer(true);
                                      double rawScore = provider.scores
                                          .fold(
                                              0,
                                              (prev, s) =>
                                                  prev + (int.tryParse(s) ?? 0))
                                          .toDouble();
                                      List<String> allStudentNames = projectStudents
                                          .map((s) =>
                                              '${s.user.firstName} ${s.user.lastName}')
                                          .toList();
                                      pdfUrl = await provider
                                          .uploadExaminer2PdfAndScore(
                                        pdfBytes: await provider.generatePdf(
                                          supervisorUsername:
                                              supervisorUsername,
                                          studentNames: allStudentNames,
                                          projectTitle: projectTitle,
                                          evaluationType: evalType,
                                          scores: provider.scores,
                                          notes: provider.notes,
                                        ),
                                        rawScore: rawScore,
                                        project: project,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'تم تقييم هذا المشروع بالفعل أو لا يمكنك التقييم')),
                                      );
                                      return;
                                    }
                                  }
                                  if (pdfUrl != null && pdfUrl.isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'تم رفع الملف بنجاح!\nرابط التحميل: $pdfUrl')),
                                    );
                                  } else if (pdfUrl == null) {
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('فشل رفع الملف!')),
                                    );
                                  }
                                },
                                style: kButtonStyle,
                                child: const Text(
                                  "حفظ النتيجة",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else if (isExaminer) {
        // Examiner: If already graded, show message and hide table
        final examiner1Score = project?.examiner1Score;
        final examiner2Score = project?.examiner2Score;
        if (examiner1Score != null && examiner2Score != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(
                      color: Colors.green,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(kCardRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'تم التقييم بالفعل',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'درجة ممتحن 1:  ${project!.examiner1Raw?.toStringAsFixed(2) ?? "-"} من 25'),
                      Text(
                          'درجة ممتحن 2: ${project.examiner2Raw?.toStringAsFixed(2) ?? "-"} من 25'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        // Examiner grading table (based on the image)
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('جدول تقييم الممتحن',
                    style: kBodyTextStyle.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: ExaminerGradingTable(
                      examinerGradeItems: examinerGradeItems,
                      totalScore: examinerGradeItems.fold(
                          0,
                          (sum, item) =>
                              sum +
                              (int.tryParse(item.scoreController.text) ?? 0)),
                      onScoreChanged: () => setState(() {}),
                      shouldFocusEmpty: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Examiner save logic
                      final firstEmptyExaminerIndex =
                          examinerGradeItems.indexWhere((item) =>
                              item.scoreController.text.trim().isEmpty);
                      if (firstEmptyExaminerIndex != -1) {
                        examinerGradeItems[firstEmptyExaminerIndex]
                                .scoreController
                                .selection =
                            TextSelection(
                                baseOffset: 0,
                                extentOffset:
                                    examinerGradeItems[firstEmptyExaminerIndex]
                                        .scoreController
                                        .text
                                        .length);
                        FocusScope.of(context).requestFocus(FocusNode());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('يرجى تعبئة جميع الدرجات قبل الحفظ')),
                        );
                        return;
                      }
                      int totalScore = examinerGradeItems.fold(
                          0,
                          (sum, item) =>
                              sum +
                              (int.tryParse(item.scoreController.text) ?? 0));
                      if (totalScore > 500) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('المجموع لا يجب أن يتجاوز 500')),
                        );
                        return;
                      }
                      final teacherProvider = context.read<TeacherProvider?>();
                      String supervisorUsername = '';
                      ProjectDetail? project;
                      int? teacherId;
                      if (teacherProvider != null &&
                          teacherProvider.currentProject != null) {
                        project = teacherProvider.currentProject;
                      }
                      if (teacherProvider != null &&
                          teacherProvider.teacher != null) {
                        teacherId = teacherProvider.teacher!.id;
                      }
                      String projectTitle = projectTitleController.text;
                      final evalType = evaluationType;
                      String? pdfUrl;
                      if (project != null && teacherId != null) {
                        // Examiner logic: use the new scores
                        double rawScore = examinerGradeItems
                            .fold(
                                0,
                                (prev, item) =>
                                    prev +
                                    (int.tryParse(item.scoreController.text) ??
                                        0))
                            .toDouble();
                        List<String> allStudentNames = projectStudents
                            .map(
                                (s) => '${s.user.firstName} ${s.user.lastName}')
                            .toList();
                        if (project.examiner1Raw == null) {
                          pdfUrl = await provider.uploadExaminer1PdfAndScore(
                            pdfBytes: await provider.generatePdf(
                              supervisorUsername: supervisorUsername,
                              studentNames: allStudentNames,
                              projectTitle: projectTitle,
                              evaluationType: evalType,
                              scores: examinerGradeItems.map((item) => item.scoreController.text).toList(),
                              notes: List.filled(examinerGradeItems.length, ''),
                            ),
                            rawScore: rawScore,
                            project: project,
                          );
                        } else if (project.examiner2Raw == null) {
                          pdfUrl = await provider.uploadExaminer2PdfAndScore(
                            pdfBytes: await provider.generatePdf(
                              supervisorUsername: supervisorUsername,
                              studentNames: allStudentNames,
                              projectTitle: projectTitle,
                              evaluationType: evalType,
                              scores: examinerGradeItems.map((item) => item.scoreController.text).toList(),
                              notes: List.filled(examinerGradeItems.length, ''),
                            ),
                            rawScore: rawScore,
                            project: project,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'تم تقييم هذا المشروع بالفعل أو لا يمكنك التقييم')),
                          );
                          return;
                        }
                        setState(() {});
                      }
                      if (pdfUrl != null && pdfUrl.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'تم رفع الملف بنجاح!\nرابط التحميل: $pdfUrl')),
                        );
                      } else if (pdfUrl == null) {
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('فشل رفع الملف!')),
                        );
                      }
                    },
                    style: kButtonStyle,
                    child: const Text('حفظ النتيجة',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'Tajawal')),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Not allowed to grade
        return Center(
          child: Text('غير مصرح لك بتقييم هذا المشروع', style: kBodyTextStyle),
        );
      }
    });
  }
}
