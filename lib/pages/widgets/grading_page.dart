import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/project_details_list.dart';
import '../../../models/student_details_list.dart';
import '../../../providers/pdf_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../providers/user_provider.dart';
import 'evaluation_status_card.dart';

const double kCardRadius = 12.0; // Define your card radius centrally

/// This is the main page widget that intelligently decides what to display.
class GradingPage extends StatefulWidget {
  final ProjectDetail project;

  const GradingPage({super.key, required this.project});

  @override
  State<GradingPage> createState() => _GradingPageState();
}

class _GradingPageState extends State<GradingPage> {
  late ProjectDetail _currentProject;

  final _projectTitleController = TextEditingController();
  List<StudentDetail> _projectStudents = [];
  bool _isLoadingStudents = true;
  GradingRole _userRole = GradingRole.notAllowed;

  @override
  void initState() {
    super.initState();

    // Initialize the new state variable with the initial project data
    _currentProject = widget.project;

    _projectTitleController.text = _currentProject.title;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pass the state variable to your methods
      _determineRoleAndInitialize(_currentProject);
      _loadStudents(_currentProject.id);
    });
  }

  /// Determines the user's role for the current project and initializes the provider.
  void _determineRoleAndInitialize(ProjectDetail project) {
    final userProvider = context.read<UserProvider>();
    final teacherProvider = context.read<TeacherProvider>();
    final pdfProvider = context.read<PdfProvider>();

    final isSupervisor = project.teacher?.id == teacherProvider.teacher?.id;
    final isExaminer = userProvider.isCurrentUserExaminer;

    GradingRole role;
    if (isSupervisor) {
      role = project.supervisorScore != null // Use the passed project object
          ? GradingRole.alreadyGraded
          : GradingRole.supervisor;
    } else if (isExaminer) {
      if (project.examiner1Score == null) { // Use the passed project object
        role = GradingRole.examiner1;
      } else if (project.examiner2Score == null) { // Use the passed project object
        role = GradingRole.examiner2;
      } else {
        role = GradingRole.alreadyGraded;
      }
    } else {
      role = GradingRole.notAllowed;
    }

    setState(() {
      _userRole = role;
    });

    pdfProvider.initializeForRole(role);
  }

  Future<void> _loadStudents(int projectId) async {
    setState(() => _isLoadingStudents = true);
    try {
      final students = await context
          .read<TeacherProvider>()
          .loadFilteredStudentForProject(projectId);
      if (mounted) {
        setState(() {
          _projectStudents = students;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load students: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingStudents = false);
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      // 1. Fetch the latest version of the project
      final newProjectDetails = await context
          .read<TeacherProvider>()
          .getProjectDetails(_currentProject.id);

      // 2. Reload the students for that project
      await _loadStudents(newProjectDetails.id);

      // 3. Update the state with the fresh data and re-evaluate the user's role
      if (mounted) {
        setState(() {
          _currentProject = newProjectDetails;
        });
        // Pass the NEW project details to the role check
        _determineRoleAndInitialize(newProjectDetails);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _projectTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Consumer<PdfProvider>(
        builder: (context, provider, child) {
          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: _buildContent(provider), // استدعاء دالة بناء المحتوى
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(PdfProvider provider) {
    switch (_userRole) {
      case GradingRole.alreadyGraded:
      // Call the new, dedicated view for this state.
        return _buildAlreadyGradedView();

      case GradingRole.notAllowed:
      // This remains the same, using the simple status card.
        return Center(
          child: _buildStatusCard(
            title: 'غير مصرح لك بالتقييم',
            message: 'أنت لست مشرفاً أو ممتحناً لهذا المشروع.',
            color: Colors.grey,
          ),
        );

      default: // Handles supervisor, examiner1, examiner2
      // This case, which shows the grading interface, is now completely separate.
        return _buildGradingInterface(provider);
    }
  }

  /// Builds the main grading UI.
  Widget _buildGradingInterface(PdfProvider provider) {
    int evaluatorsCount = 0;
    if (_currentProject.supervisorScore != null) evaluatorsCount++; // Use _currentProject
    if (_currentProject.examiner1Score != null) evaluatorsCount++;  // Use _currentProject
    if (_currentProject.examiner2Score != null) evaluatorsCount++;  // Use _currentProject

    final bool isComplete = _currentProject.supervisorScore != null && // Use _currentProject
        _currentProject.examiner1Score != null &&                     // Use _currentProject
        _currentProject.examiner2Score != null;                      // Use _currentProject

    double? finalScore;
    if (isComplete) {
      finalScore = (_currentProject.supervisorScore ?? 0.0) +      // Use _currentProject
          (_currentProject.examiner1Score ?? 0.0) +                // Use _currentProject
          (_currentProject.examiner2Score ?? 0.0);                 // Use _currentProject
    }
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // Using a fixed value
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _userRole == GradingRole.supervisor
                    ? 'تقييم المشرف'
                    : 'تقييم الممتحن',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Common Fields
              _buildProjectInfoSection(),
              const SizedBox(height: 20),

              // Supervisor-specific fields
              if (_userRole == GradingRole.supervisor) ...[
                _buildSupervisorExtraScores(provider),
                const SizedBox(height: 20),
              ],

              // The new, reusable grading data table
              if (provider.currentEvaluationItems.isNotEmpty)
                GradingDataTable(
                  // Use a key to ensure the widget rebuilds when the role changes
                  key: ValueKey(_userRole),
                  items: provider.currentEvaluationItems,
                  initialScores: provider.scores,
                  initialNotes: provider.notes,
                  onScoreChanged: provider.setScore,
                  onNoteChanged: provider.setNote,
                  totalScore: provider.calculateTotalScore(),
                ),

              const SizedBox(height: 30),
              _buildSaveButton(provider),
              const SizedBox(height: 30),
              EvaluationStatusCard(
                finalScore: finalScore,
                isComplete: isComplete,
                evaluatorsCount: evaluatorsCount,
                cardRadius: kCardRadius, // استخدام الثابت الموجود
              ),
            ],
          ),
        ),
      ),
    );
  }
  /// Builds a centered view for projects that are already graded,
  /// showing a confirmation title and the final evaluation status card.
  Widget _buildAlreadyGradedView() {
    // --- Step 1: Move the calculation logic here ---
    int evaluatorsCount = 0;
    if (_currentProject.supervisorScore != null) evaluatorsCount++;
    if (_currentProject.examiner1Score != null) evaluatorsCount++;
    if (_currentProject.examiner2Score != null) evaluatorsCount++;

    final bool isComplete = _currentProject.supervisorScore != null &&
        _currentProject.examiner1Score != null &&
        _currentProject.examiner2Score != null;

    double? finalScore;
    if (isComplete) {
      // Note: This assumes the scores are out of 100. Adjust if your logic is different.
      // For example, if it's a sum of scores, the calculation is correct.
      // If it's an average, you would divide by 3.
      finalScore = (_currentProject.supervisorScore ?? 0.0) +
          (_currentProject.examiner1Score ?? 0.0) +
          (_currentProject.examiner2Score ?? 0.0);
    }

    // --- Step 2: Build the combined UI ---
    return Center(
      child: Padding(
        // Use standard padding to keep it away from screen edges.
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          // Constrain width for a consistent look on all devices.
          constraints: const BoxConstraints(maxWidth: 450),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Keep the card height compact.
                children: [
                  // The title you requested, styled according to the theme.
                  Text(
                    'تم التقييم بالفعل',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800], // Use success color from theme.
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هذا المشروع تم تقييمه. يمكنك رؤية الحالة النهائية أدناه.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),

                  // Add a visual separator for a cleaner look.
                  Divider(thickness: 1, indent: 20, endIndent: 20, color: Colors.grey[200]),
                  const SizedBox(height: 20),

                  // The EvaluationStatusCard showing the final results.
                  EvaluationStatusCard(
                    finalScore: finalScore,
                    isComplete: isComplete,
                    evaluatorsCount: evaluatorsCount,
                    cardRadius: 15.0, // Use a radius that matches your design.
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildProjectInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A label to introduce the section, similar to the "مرحباً بك" card
        const Text(
          "معلومات المشروع",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff00577B),
          ),
        ),
        const SizedBox(height: 16),

        // Conditional display for the student dropdown
        if (_isLoadingStudents)
          const Center(child: CircularProgressIndicator())
        else
        // Styled container for the dropdown
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: DropdownButtonFormField<StudentDetail>(
              items: _projectStudents
                  .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text('${s.user.firstName} ${s.user.lastName}')))
                  .toList(),
              onChanged: (val) {
                // Logic for selecting student if needed
              },
              // The decoration is applied here
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xff00577B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_search_outlined, // More specific icon
                    color: Color(0xff00577B),
                    size: 20,
                  ),
                ),
                hintText: "تحديد الطالب", // Using hintText instead of labelText
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none, // Hide the default border
                ),
                filled: true,
                fillColor: Colors.transparent, // Background color is from the container
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
              value: _projectStudents.isNotEmpty ? _projectStudents.first : null,
              // Styling the dropdown icon to match the theme
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xff00577B)),
            ),
          ),
        const SizedBox(height: 16),

        // Styled container for the project title TextFormField
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: _projectTitleController,
            readOnly: true, // Field is not editable
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xff00577B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.article_outlined, // Icon for a title or document
                  color: Color(0xff00577B),
                  size: 20,
                ),
              ),
              // The label is part of the hint text now
              hintText: "اسم المشروع",
              hintStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100, // Slightly different fill color for read-only
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupervisorExtraScores(PdfProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional: Add a title for this section as well
        const Text(
          "الدرجات الإضافية",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff00577B),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coordinator Score Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextFormField(
                  initialValue: provider.coordinatorScore,
                  onChanged: provider.setCoordinatorScore,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center, // Center the number input
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xff00577B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.supervised_user_circle_outlined,
                        color: Color(0xff00577B),
                        size: 20,
                      ),
                    ),
                    hintText: "درجة المنسق (5)",
                    hintStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Head of Department Score Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextFormField(
                  initialValue: provider.headScore,
                  onChanged: provider.setHeadScore,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xff00577B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Color(0xff00577B),
                        size: 20,
                      ),
                    ),
                    hintText: "درجة الرئيس (5)",
                    hintStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton(PdfProvider provider) {
    return SizedBox(
      // Make the button take the full width for a modern look
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        // Apply the detailed styling here
        style: ElevatedButton.styleFrom(
          // Background color from the login page style
          backgroundColor: const Color(0xff00577B),
          // Text and icon color
          foregroundColor: Colors.white,
          // Elevation for the shadow effect
          elevation: 8,
          // Shadow color with opacity to create a "glow" effect
          shadowColor: const Color(0xff00577B).withOpacity(0.3),
          // Rounded corners to match the card-based UI style
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: provider.isLoading
            ? null // Disable button when loading
            : () async {
          try {
            final supervisor = _currentProject.teacher;
            final supervisorName =
                '${supervisor?.user.firstName} ${supervisor?.user.lastName}';

            await provider.saveGrading(
              project: _currentProject,
              supervisorUsername: supervisorName,
              studentNames: _projectStudents
                  .map((s) => '${s.user.firstName} ${s.user.lastName}')
                  .toList(),
              projectTitle: _projectTitleController.text,
              evaluationType: 'جماعي', // Or get from UI
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('تم حفظ التقييم بنجاح!'),
                  backgroundColor: Colors.green));

              // --- THIS IS THE FIX ---
              // Instead of just checking the role, refresh all data from the server.
              await _refreshData();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('فشل الحفظ: $e'),
                  backgroundColor: Colors.red));
            }
          }
        },
        // The child of the button changes based on the loading state
        child: provider.isLoading
        // Use a sized box for the indicator to control its size, matching the login button
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
        // Text style for the button's label
            : const Text(
          'حفظ النتيجة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16, // Adjusted to match the login button's font size
          ),
        ),
      ),
    );
  }

  /// A helper widget to display a themed status card.
  /// It applies the consistent styling for borders, colors, and typography.
  /// A helper widget to display a themed status card.
  /// It is centered and has a constrained width to avoid filling the screen.
  Widget _buildStatusCard({
    required String title,
    required String message,
    required Color color,
  }) {
    final Color backgroundColor = color == Colors.green ? Colors.green[50]! : Colors.grey[100]!;
    final Color textAndBorderColor = color == Colors.green ? Colors.green[800]! : Colors.grey[700]!;

    // This outer padding ensures the card never touches the screen edges.
    return Padding(
      padding: const EdgeInsets.all(24.0),
      // NEW: Constrain the maximum width of the card.
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400, // The card will not grow wider than 400 logical pixels.
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0), // Slightly more internal padding.
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: textAndBorderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Crucial for keeping the card's height compact.
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textAndBorderColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reusable, stateful widget for displaying the grading table.
/// It manages its own controllers, making it self-contained and easy to reuse.
class GradingDataTable extends StatefulWidget {
  final List<EvaluationItem> items;
  final List<String> initialScores;
  final List<String> initialNotes;
  final void Function(int, String) onScoreChanged;
  final void Function(int, String) onNoteChanged;
  final int totalScore;

  const GradingDataTable({
    Key? key,
    required this.items,
    required this.initialScores,
    required this.initialNotes,
    required this.onScoreChanged,
    required this.onNoteChanged,
    required this.totalScore,
  }) : super(key: key);

  @override
  _GradingDataTableState createState() => _GradingDataTableState();
}

class _GradingDataTableState extends State<GradingDataTable> {
  late final List<TextEditingController> _scoreControllers;
  late final List<TextEditingController> _noteControllers;

  @override
  void initState() {
    super.initState();
    _scoreControllers = List.generate(
      widget.items.length,
      (i) => TextEditingController(text: widget.initialScores[i]),
    );
    _noteControllers = List.generate(
      widget.items.length,
      (i) => TextEditingController(text: widget.initialNotes[i]),
    );

    // Add listeners to controllers to link them back to the provider
    for (int i = 0; i < widget.items.length; i++) {
      final maxScore = widget.items[i].maxScore;
      _scoreControllers[i].addListener(() {
        // Score capping logic
        final text = _scoreControllers[i].text;
        if (text.isNotEmpty) {
          final value = int.tryParse(text);
          if (value != null && value > maxScore) {
            _scoreControllers[i].text = maxScore.toString();
            _scoreControllers[i].selection = TextSelection.fromPosition(
                TextPosition(offset: _scoreControllers[i].text.length));
          }
        }
        widget.onScoreChanged(i, _scoreControllers[i].text);
      });

      _noteControllers[i].addListener(() {
        widget.onNoteChanged(i, _noteControllers[i].text);
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _scoreControllers) {
      controller.dispose();
    }
    for (final controller in _noteControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            // Table Header
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: const [
                _HeaderCell('البند'),
                _HeaderCell('الدرجة القصوى'),
                _HeaderCell('الدرجة'),
                _HeaderCell('ملاحظات'),
              ],
            ),
            // Table Body
            ...widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return TableRow(
                children: [
                  _TableCell(Text(item.detail, textAlign: TextAlign.right)),
                  _TableCell(Text(item.maxScore.toString(),
                      textAlign: TextAlign.center)),
                  _TableCell(
                    TextFormField(
                      controller: _scoreControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          border: InputBorder.none, isDense: true),
                    ),
                  ),
                  _TableCell(
                    TextFormField(
                      controller: _noteControllers[index],
                      decoration: const InputDecoration(
                          border: InputBorder.none, isDense: true),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        // Total Score Row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('المجموع: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${widget.totalScore} / 500',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

// Helper widgets for table cells to reduce repetition
class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _TableCell extends StatelessWidget {
  final Widget child;

  const _TableCell(this.child);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: child,
    );
  }
}
