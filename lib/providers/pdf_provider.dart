import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gradpro/models/project_details_list.dart';
import 'package:gradpro/models/project_list.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import '../services/file_services.dart';
import '../services/models_services.dart'; // Ensure this has your patchProject method
import 'package:path_provider/path_provider.dart';

// Helper to create a temporary file from bytes.
Future<File> createTemporaryFile(Uint8List uint8List) async {
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
  await tempFile.writeAsBytes(uint8List);
  return tempFile;
}

class EvaluationItem {
  final String section;
  final String detail;
  final int maxScore;
  EvaluationItem({required this.section, required this.detail, required this.maxScore});
}

// Enum to define user roles for clarity and type safety.
enum GradingRole { supervisor, examiner1, examiner2, notAllowed, alreadyGraded }

class PdfProvider extends ChangeNotifier {
  // --- STATE ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GradingRole _currentRole = GradingRole.notAllowed;
  GradingRole get currentRole => _currentRole;

  List<EvaluationItem> _currentEvaluationItems = [];
  List<EvaluationItem> get currentEvaluationItems => _currentEvaluationItems;

  List<String> scores = [];
  List<String> notes = [];
  String coordinatorScore = '';
  String headScore = '';

  // --- PRIVATE DATA ---
  final List<EvaluationItem> _supervisorItems = [
    EvaluationItem(section: 'Teamwork', detail: 'Meetings and Sessions', maxScore: 10),
    EvaluationItem(section: 'Teamwork', detail: 'Attendance and Absence', maxScore: 10),
    EvaluationItem(section: 'Teamwork', detail: 'Commitment to Deadlines', maxScore: 10),
    // ... Add all other supervisor items here
  ];

  final List<EvaluationItem> _examinerItems = [
    EvaluationItem(section: 'Presentation & Seminar', detail: 'الالتزام بمواعيد الإنجاز', maxScore: 20),
    EvaluationItem(section: 'Presentation & Seminar', detail: 'المساهمة والمشاركة والتفاعل', maxScore: 20),
    EvaluationItem(section: 'Presentation & Seminar', detail: 'مهارات الإلقاء', maxScore: 30),
    // ... Add all other examiner items here
  ];

  void initializeForRole(GradingRole role) {
    _currentRole = role;
    if (role == GradingRole.supervisor) {
      _currentEvaluationItems = _supervisorItems;
    } else if (role == GradingRole.examiner1 || role == GradingRole.examiner2) {
      _currentEvaluationItems = _examinerItems;
    } else {
      _currentEvaluationItems = [];
    }

    scores = List.generate(_currentEvaluationItems.length, (_) => '');
    notes = List.generate(_currentEvaluationItems.length, (_) => '');
    coordinatorScore = '';
    headScore = '';

    notifyListeners();
  }

  // --- STATE UPDATE METHODS ---
  void setScore(int index, String value) {
    if (index < scores.length) {
      scores[index] = value;
      notifyListeners();
    }
  }

  void setNote(int index, String value) {
    if (index < notes.length) {
      notes[index] = value;
      notifyListeners();
    }
  }

  void setCoordinatorScore(String value) {
    coordinatorScore = value;
    notifyListeners();
  }

  void setHeadScore(String value) {
    headScore = value;
    notifyListeners();
  }

  // --- CORE LOGIC ---
  int calculateTotalScore() {
    return scores.fold(0, (total, score) => total + (int.tryParse(score) ?? 0));
  }

  String? validateScores() {
    for (int i = 0; i < _currentEvaluationItems.length; i++) {
      if (scores[i].isEmpty) {
        return 'يرجى تعبئة جميع الدرجات قبل الحفظ';
      }
      final parsed = int.tryParse(scores[i]);
      final maxScore = _currentEvaluationItems[i].maxScore;
      if (parsed == null || parsed < 0 || parsed > maxScore) {
        return 'الدرجة في البند رقم ${i + 1} غير صحيحة أو تتجاوز الحد الأقصى ($maxScore)';
      }
    }
    return null;
  }

  /// **CORRECTED: Calls patchProject with the correct named arguments.**
  Future<String?> saveGrading({
    required ProjectDetail project,
    required String supervisorUsername,
    required List<String> studentNames,
    required String projectTitle,
    required String evaluationType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final validationError = validateScores();
      if (validationError != null) {
        throw Exception(validationError);
      }

      // 1. Generate PDF
      final pdfBytes = await _generatePdf(
        supervisorUsername: supervisorUsername,
        studentNames: studentNames,
        projectTitle: projectTitle,
        evaluationType: evaluationType,
      );

      // 2. Upload PDF
      final tempFile = await createTemporaryFile(pdfBytes);
      final fileResponse = await FileService().uploadFile(tempFile);
      final pdfUrl = fileResponse?.data.downloadPage;

      // 3. Calculate score
      final rawScore = calculateTotalScore().toDouble();

      // 4. Call patchProject with the correct named arguments based on role
      switch (_currentRole) {
        case GradingRole.supervisor:
          await patchProject(
            id: project.id,
            teacher: project.teacher?.id,
            progression: project.progression,
            deliveryDate: project.deliveryDate?.toIso8601String(),
            mainSuggestion: project.mainSuggestion?.id,
            supervisorGrade: rawScore / 12.5, // 40 point scale
            departmentHeadGrade: double.tryParse(headScore) ?? 0.0,
            coordinatorGrade: double.tryParse(coordinatorScore) ?? 0.0,
            pdfSupervisor: pdfUrl,
          );
          break;
        case GradingRole.examiner1:
          await patchProject(
            id: project.id,
            teacher: project.teacher?.id,
            progression: project.progression,
            deliveryDate: project.deliveryDate?.toIso8601String(),
            mainSuggestion: project.mainSuggestion?.id,
            firstGrading: rawScore / 20, // 25 point scale
            pdfExaminer1: pdfUrl,
          );
          break;
        case GradingRole.examiner2:
          await patchProject(
            id: project.id,
            teacher: project.teacher?.id,
            progression: project.progression,
            deliveryDate: project.deliveryDate?.toIso8601String(),
            mainSuggestion: project.mainSuggestion?.id,
            secondGrading: rawScore / 20, // 25 point scale
            pdfExaminer2: pdfUrl,
          );
          break;
        default:
          throw Exception("Invalid role for saving.");
      }

      return pdfUrl;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- PRIVATE HELPERS ---
  Future<Uint8List> _generatePdf({
    required String supervisorUsername,
    required List<String> studentNames,
    required String projectTitle,
    required String evaluationType,
  }) async {
    // PDF generation logic remains the same.
    final pdfDoc = pw.Document();
    // TODO:pdf generation logic
    return pdfDoc.save();
  }
}