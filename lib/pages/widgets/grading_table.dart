
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../models/project_details_list.dart';
import '../../models/student_details_list.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/pdf_provider.dart';
import 'suggestion_styles.dart';

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
  final List<_ExaminerGradeItem> examinerGradeItems = [
    // العرض والسمنار
    _ExaminerGradeItem('الالتزام بمواعيد الإنجاز', 20),
    _ExaminerGradeItem('المساهمة والمشاركة في النقاش', 20),
    _ExaminerGradeItem('مهارات الإلقاء', 30),
    _ExaminerGradeItem('العرض والتسلسل المنطقي', 20),
    _ExaminerGradeItem('استخدام الأدوات', 10),
    // فهم المشروع
    _ExaminerGradeItem('الإلمام بالمشكلة ودراسة الحالة', 20),
    _ExaminerGradeItem('مجال وحدود المشروع', 20),
    _ExaminerGradeItem('الأهداف والمزايا والفوائد', 20),
    _ExaminerGradeItem('الأسلوب (Methodology)', 20),
    _ExaminerGradeItem('الإجابة على الأسئلة', 20),
    // تصميم المشروع
    _ExaminerGradeItem('التصميم الهيكلي (Architecture)', 30),
    _ExaminerGradeItem('تصميم الواجهات (Interfaces)', 30),
    _ExaminerGradeItem('تصميم قواعد البيانات (Persistence)', 30),
    _ExaminerGradeItem('تصميم الخوارزميات (Algorithms)', 30),
    _ExaminerGradeItem('الأمن والسلامة (Safety & Security)', 30),
    // التقرير
    _ExaminerGradeItem('الشكل', 20),
    _ExaminerGradeItem('الكمال', 20),
    _ExaminerGradeItem('الجودة', 20),
    _ExaminerGradeItem('استخدام الجيد للأدوات', 20),
    _ExaminerGradeItem('اللغة العربية', 20),
  ];

  // Add refresh method
  Future<void> _refreshGradingStatus() async {
    final teacherProvider = context.read<TeacherProvider>();
    if (widget.project != null) {
      await teacherProvider.refreshCurrentProject();
      final students = await teacherProvider.loadFilteredStudentForProject(widget.project!.id);
      setState(() {
        projectStudents = students;
        if (students.isNotEmpty) selectedStudent = students.first;
        isLoadingStudents = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      projectTitleController.text = widget.project!.title ?? '';
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
    final userProvider = context.read<UserProvider>();
    final currentTeacherId = teacherProvider.teacher?.id;
    final isSupervisor = widget.project?.teacher?.id == currentTeacherId;
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      final isExaminer = provider.isExaminer;
      if (isSupervisor) {
        // Supervisor grading table (current UI)
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
                    provider.isExaminer
                        ? TextFormField(
                            initialValue: provider.examinerCollegeScore,
                            onChanged: (val) =>
                                provider.setExaminerCollegeScore(val),
                            decoration: InputDecoration(
                              labelText: 'درجة الكلية (من 25)',
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
                            keyboardType: TextInputType.number,
                          )
                        : Row(
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
                                  onChanged: (val) =>
                                      provider.setHeadScore(val),
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: provider.currentEvaluationItems.length,
                      itemBuilder: (context, index) {
                        final item = provider.currentEvaluationItems[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Colors.white
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(kCardRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(item.detail,
                                      style: kBodyTextStyle),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(item.maxScore.toString(),
                                      style: kBodyTextStyle),
                                ),
                              ),
                              SizedBox(
                                width: 56, // Enough for 3 characters
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    initialValue: provider.scores[index],
                                    onChanged: (val) => provider.setScore(index, val),
                                    decoration: InputDecoration(
                                      hintText: 'الدرجة',
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
                                        vertical: 18, horizontal: 10), // Reduced padding
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    initialValue: provider.notes[index],
                                    onChanged: (val) =>
                                        provider.setNote(index, val),
                                    decoration: InputDecoration(
                                      hintText: 'ملاحظات',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            kCardRadius),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            kCardRadius),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 18, horizontal: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                                  final userProvider =
                                      context.read<UserProvider?>();
                                  String supervisorUsername = '';
                                  int projectId = 0;
                                  ProjectDetail? project;
                                  int? teacherId;
                                  if (teacherProvider != null &&
                                      teacherProvider.currentProject != null) {
                                    project = teacherProvider.currentProject;
                                    projectId = project?.id ?? 0;
                                    if (teacherProvider
                                                .currentProject!.teacher !=
                                            null &&
                                        teacherProvider.currentProject!.teacher!
                                                .user !=
                                            null) {
                                      supervisorUsername = teacherProvider
                                              .currentProject!
                                              .teacher!
                                              .user
                                              .username ??
                                          '';
                                    }
                                  }
                                  if (teacherProvider != null &&
                                      teacherProvider.teacher != null) {
                                    teacherId = teacherProvider.teacher!.id;
                                  }
                                  String studentName = selectedStudent != null
                                      ? '${selectedStudent!.user.firstName} ${selectedStudent!.user.lastName}'
                                      : '';
                                  String projectTitle =
                                      projectTitleController.text;
                                  final evalType = evaluationType;
                                  String? pdfUrl;
                                  if (project != null && teacherId != null) {
                                    if (project.teacher?.id == teacherId) {
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
                                          .map((s) => '${s.user.firstName} ${s.user.lastName}')
                                          .toList();
                                      pdfUrl = await provider
                                          .uploadSupervisorPdfAndScores(
                                        pdfBytes: await provider.generatePdf(
                                          supervisorUsername:
                                              supervisorUsername,
                                          studentNames: allStudentNames,
                                          projectTitle: projectTitle,
                                          evaluationType: evalType,
                                        ),
                                        supervisorRaw: supervisorRaw,
                                        headScore: headScore,
                                        coordinatorScore: coordinatorScore,
                                        project: project,
                                      );
                                    } else if (project.examiner1Raw == null) {
                                      double rawScore = provider.scores
                                          .fold(
                                              0,
                                              (prev, s) =>
                                                  prev + (int.tryParse(s) ?? 0))
                                          .toDouble();
                                      List<String> allStudentNames = projectStudents
                                          .map((s) => '${s.user.firstName} ${s.user.lastName}')
                                          .toList();
                                      pdfUrl = await provider
                                          .uploadExaminer1PdfAndScore(
                                        pdfBytes: await provider.generatePdf(
                                          supervisorUsername:
                                              supervisorUsername,
                                          studentNames: allStudentNames,
                                          projectTitle: projectTitle,
                                          evaluationType: evalType,
                                        ),
                                        rawScore: rawScore,
                                        project: project,
                                      );
                                    } else if (project.examiner2Raw == null) {
                                      double rawScore = provider.scores
                                          .fold(
                                              0,
                                              (prev, s) =>
                                                  prev + (int.tryParse(s) ?? 0))
                                          .toDouble();
                                      List<String> allStudentNames = projectStudents
                                          .map((s) => '${s.user.firstName} ${s.user.lastName}')
                                          .toList();
                                      pdfUrl = await provider
                                          .uploadExaminer2PdfAndScore(
                                        pdfBytes: await provider.generatePdf(
                                          supervisorUsername:
                                              supervisorUsername,
                                          studentNames: allStudentNames,
                                          projectTitle: projectTitle,
                                          evaluationType: evalType,
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
                Text('جدول تقييم الممتحن', style: kBodyTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 20),
                _buildExaminerGradingTable(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Examiner save logic
                    int totalScore = examinerGradeItems.fold(0, (sum, item) => sum + (int.tryParse(item.scoreController.text) ?? 0));
                    if (totalScore > 500) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('المجموع لا يجب أن يتجاوز 500')),
                      );
                      return;
                    }
                    final teacherProvider = context.read<TeacherProvider?>();
                    final userProvider = context.read<UserProvider?>();
                    String supervisorUsername = '';
                    int projectId = 0;
                    ProjectDetail? project;
                    int? teacherId;
                    if (teacherProvider != null && teacherProvider.currentProject != null) {
                      project = teacherProvider.currentProject;
                      projectId = project?.id ?? 0;
                      if (teacherProvider.currentProject!.teacher != null &&
                          teacherProvider.currentProject!.teacher!.user != null) {
                        supervisorUsername = teacherProvider.currentProject!.teacher!.user.username ?? '';
                      }
                    }
                    if (teacherProvider != null && teacherProvider.teacher != null) {
                      teacherId = teacherProvider.teacher!.id;
                    }
                    String studentName = selectedStudent != null
                        ? '${selectedStudent!.user.firstName} ${selectedStudent!.user.lastName}'
                        : '';
                    String projectTitle = projectTitleController.text;
                    final evalType = evaluationType;
                    String? pdfUrl;
                    if (project != null && teacherId != null) {
                      // Examiner logic: use the new scores
                      double rawScore = examinerGradeItems.fold(0, (prev, item) => prev + (int.tryParse(item.scoreController.text) ?? 0)).toDouble();
                      List<String> allStudentNames = projectStudents.map((s) => '${s.user.firstName} ${s.user.lastName}').toList();
                      if (project.examiner1Raw == null) {
                        pdfUrl = await provider.uploadExaminer1PdfAndScore(
                          pdfBytes: await provider.generatePdf(
                            supervisorUsername: supervisorUsername,
                            studentNames: allStudentNames,
                            projectTitle: projectTitle,
                            evaluationType: evalType,
                            // Optionally pass examiner notes if needed
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
                            // Optionally pass examiner notes if needed
                          ),
                          rawScore: rawScore,
                          project: project,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تقييم هذا المشروع بالفعل أو لا يمكنك التقييم')),
                        );
                        return;
                      }
                    }
                    if (pdfUrl != null && pdfUrl.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم رفع الملف بنجاح!\nرابط التحميل: $pdfUrl')),
                      );
                    } else if (pdfUrl == null) {
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('فشل رفع الملف!')),
                      );
                    }
                  },
                  style: kButtonStyle,
                  child: const Text('حفظ النتيجة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white, fontFamily: 'Tajawal')),
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

  // Stub for examiner grading table UI
  Widget _buildExaminerGradingTable() {
    int totalScore = examinerGradeItems.fold(0, (sum, item) => sum + (int.tryParse(item.scoreController.text) ?? 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('البند', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('الدرجة القصوى', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('الدرجة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('ملاحظات', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...examinerGradeItems.map((item) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item.title, textAlign: TextAlign.right),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item.maxScore.toString(), textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: item.scoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'الدرجة',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: item.noteController,
                    decoration: const InputDecoration(
                      hintText: 'ملاحظات',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('المجموع: ', style: kBodyTextStyle.copyWith(fontWeight: FontWeight.bold)),
            Text('$totalScore / 500', style: kBodyTextStyle.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

// Helper class for examiner grading items
class _ExaminerGradeItem {
  final String title;
  final int maxScore;
  final TextEditingController scoreController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  _ExaminerGradeItem(this.title, this.maxScore);
} 