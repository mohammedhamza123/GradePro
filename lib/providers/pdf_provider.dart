import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gradpro/models/project_details_list.dart';
import 'package:gradpro/models/project_list.dart'; // Add this import
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import '../pages/widgets/widget_pdf.dart';
import '../services/file_services.dart';
import '../services/models_services.dart'; // Add this import
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // Added for jsonDecode
import 'package:http/http.dart' as http; // Added for http
import '../services/internet_services.dart'; // Added for InternetService
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfp;

// دالة عامة لإنشاء ملف مؤقت من Uint8List
Future<File> createTemporaryFile(Uint8List uint8List) async {
  Directory tempDir = await Directory.systemTemp.createTemp('temp_directory');
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  File tempFile = File('${tempDir.path}/$fileName');
  await tempFile.writeAsBytes(uint8List);
  return tempFile;
}

class EvaluationItem {
  final String section;
  final String detail;
  final int maxScore;
  EvaluationItem(
      {required this.section, required this.detail, required this.maxScore});
}

class PdfProvider extends ChangeNotifier {
  // final PdfStorageService _storageService = PdfStorageService();
  //
  // List<String> header = [
  //   'المعيار',
  //   'الدرجة العظمي',
  //   'الطالب الاول',
  //   'الطالب الثاني'
  // ];
  // List<String> dataColumn1 = [
  //   'فكرة المشروع',
  //   'مطابقة الوثيقة لموضوع المشروع',
  //   'شمولية الوثيقة لكافة جوانب الموضوع',
  //   'التحليل و التصميم',
  //   'البناء و البرمجة',
  //   'إستخدام تقنيات جديدة',
  //   'الختبار وتشغيل النظام',
  //   'ادة العرض التقديمي وتناسبه مع الوقت المحدد',
  //   'لقاء الطالب و قدرته على الإقناع',
  //   'إجابة السئلة',
  //   'حسن سلوك الطالب',
  // ];
  // List<String> dataColumn2 = [
  //   '2',
  //   '2',
  //   '3',
  //   '2',
  //   '2',
  //   '4',
  //   '2',
  //   '3',
  //   '3',
  //   '5',
  //   '2'
  // ];
  //
  List<String> editableColumn3 = List.generate(11, (index) => '');
  List<String> editableColumn4 = List.generate(11, (index) => '');

  bool isFileLoading = false;

  // بنود التقييم للمشرف (الحالية)
  List<EvaluationItem> evaluationItems = [
    EvaluationItem(
        section: 'Teamwork', detail: 'Meetings and Sessions', maxScore: 10),
    EvaluationItem(
        section: 'Teamwork', detail: 'Attendance and Absence', maxScore: 10),
    EvaluationItem(
        section: 'Teamwork', detail: 'Commitment to Deadlines', maxScore: 10),
    EvaluationItem(
        section: 'Teamwork',
        detail: 'Contribution and Interaction',
        maxScore: 20),
    EvaluationItem(
        section: 'Relations & Communication',
        detail: 'Quality of Relations',
        maxScore: 10),
    EvaluationItem(
        section: 'Relations & Communication',
        detail: 'Enthusiasm for Work',
        maxScore: 10),
    EvaluationItem(
        section: 'Relations & Communication',
        detail: 'Communication',
        maxScore: 10),
    EvaluationItem(
        section: 'Relations & Communication',
        detail: 'Leadership',
        maxScore: 10),
    EvaluationItem(
        section: 'Project Analysis', detail: 'Problem to Solve', maxScore: 10),
    EvaluationItem(
        section: 'Project Analysis',
        detail: 'Literature Review and Case Study',
        maxScore: 10),
    EvaluationItem(
        section: 'Project Analysis',
        detail: 'Project Scope and Boundaries',
        maxScore: 10),
    EvaluationItem(
        section: 'Project Analysis',
        detail: 'Objectives and Benefits',
        maxScore: 10),
    EvaluationItem(
        section: 'Project Analysis', detail: 'Methodology', maxScore: 20),
    EvaluationItem(
        section: 'System Design', detail: 'Architecture Design', maxScore: 20),
    EvaluationItem(
        section: 'System Design', detail: 'Interfaces Design', maxScore: 20),
    EvaluationItem(
        section: 'System Design',
        detail: 'Database Design (Persistence)',
        maxScore: 20),
    EvaluationItem(
        section: 'System Design', detail: 'Algorithms Design', maxScore: 20),
    EvaluationItem(
        section: 'System Design', detail: 'Safety & Security', maxScore: 20),
    EvaluationItem(
        section: 'System Development', detail: 'Quality Plan', maxScore: 20),
    EvaluationItem(
        section: 'System Development',
        detail: 'Coding and Programming',
        maxScore: 20),
    EvaluationItem(
        section: 'System Development',
        detail: 'Testing and Test Cases',
        maxScore: 20),
    EvaluationItem(
        section: 'Presentation & Performance',
        detail: 'Presentation',
        maxScore: 20),
    EvaluationItem(
        section: 'Presentation & Performance',
        detail: 'Participation',
        maxScore: 20),
    EvaluationItem(
        section: 'Presentation & Performance',
        detail: 'Performance',
        maxScore: 20),
    EvaluationItem(
        section: 'Presentation & Performance',
        detail: 'Good Use of Tools',
        maxScore: 20),
    EvaluationItem(
        section: 'Final Appearance', detail: 'Appearance', maxScore: 20),
    EvaluationItem(
        section: 'Final Appearance', detail: 'Perfection', maxScore: 20),
    EvaluationItem(
        section: 'Final Appearance', detail: 'Quality', maxScore: 20),
    EvaluationItem(
        section: 'Final Appearance', detail: 'Good Use of Tools', maxScore: 20),
    EvaluationItem(
        section: 'Final Appearance', detail: 'Arabic Language', maxScore: 20),
  ];

  // بنود التقييم للممتحن (Examiner) بالعربي كما في الصورة
  List<EvaluationItem> examinerEvaluationItems = [
    EvaluationItem(
        section: 'Presentation & Seminar',
        detail: 'Commitment to Deadlines',
        maxScore: 20),
    EvaluationItem(
        section: 'Presentation & Seminar',
        detail: 'Contribution and Interaction',
        maxScore: 20),
    EvaluationItem(
        section: 'Presentation & Seminar',
        detail: 'Presentation Skills',
        maxScore: 30),
    EvaluationItem(
        section: 'Presentation & Seminar',
        detail: 'Clarity and Logical Sequence',
        maxScore: 30),
    EvaluationItem(
        section: 'Presentation & Seminar',
        detail: 'Use of Tools',
        maxScore: 20),
    EvaluationItem(
        section: 'Presentation & Seminar',
        detail: 'Answering Questions',
        maxScore: 30),
    EvaluationItem(
        section: 'Project Understanding',
        detail: 'Problem to Solve',
        maxScore: 20),
    EvaluationItem(
        section: 'Project Understanding',
        detail: 'Literature Review and Case Study',
        maxScore: 20),
    EvaluationItem(
        section: 'Project Understanding',
        detail: 'Project Scope and Boundaries',
        maxScore: 20),
    EvaluationItem(
        section: 'Project Understanding',
        detail: 'Objectives and Benefits',
        maxScore: 20),
    EvaluationItem(
        section: 'Project Understanding', detail: 'Methodology', maxScore: 20),
    EvaluationItem(
        section: 'Project Design', detail: 'Architecture Design', maxScore: 30),
    EvaluationItem(
        section: 'Project Design', detail: 'Interfaces Design', maxScore: 30),
    EvaluationItem(
        section: 'Project Design',
        detail: 'Database Design (Persistence)',
        maxScore: 30),
    EvaluationItem(
        section: 'Project Design', detail: 'Algorithms Design', maxScore: 30),
    EvaluationItem(
        section: 'Project Design', detail: 'Safety & Security', maxScore: 30),
    EvaluationItem(section: 'Report', detail: 'Appearance', maxScore: 20),
    EvaluationItem(section: 'Report', detail: 'Perfection', maxScore: 20),
    EvaluationItem(section: 'Report', detail: 'Quality', maxScore: 20),
    EvaluationItem(
        section: 'Report', detail: 'Good Use of Tools', maxScore: 20),
    EvaluationItem(section: 'Report', detail: 'Arabic Language', maxScore: 20),
  ];

  // Getter للوصول إلى البنود حسب نوع المستخدم
  List<EvaluationItem> get currentEvaluationItems =>
      isExaminer ? examinerEvaluationItems : evaluationItems;

  // متغيرات الدرجات والملاحظات لكل بند
  List<String> scores = List.generate(30, (index) => '');
  List<String> notes = List.generate(30, (index) => '');

  // متغيرات جديدة لدرجات منسق المشاريع ورئيس القسم
  String coordinatorScore = '';
  String headScore = '';
  bool isExaminer = false; // يجب ضبط هذه القيمة من مكان الاستدعاء حسب المستخدم
  String examinerCollegeScore = '';

  // دالة لتحديث حجم المصفوفات حسب نوع المستخدم
  void updateArraySizes() {
    final targetSize =
        isExaminer ? examinerEvaluationItems.length : evaluationItems.length;

    // توسيع المصفوفات إذا كانت أصغر من المطلوب
    if (scores.length < targetSize) {
      scores.addAll(List.generate(targetSize - scores.length, (index) => ''));
    }
    if (notes.length < targetSize) {
      notes.addAll(List.generate(targetSize - notes.length, (index) => ''));
    }

    // تقليص المصفوفات إذا كانت أكبر من المطلوب
    if (scores.length > targetSize) {
      scores = scores.sublist(0, targetSize);
    }
    if (notes.length > targetSize) {
      notes = notes.sublist(0, targetSize);
    }

    notifyListeners();
  }

  void setEditable3Value(int index, String value) {
    editableColumn3[index] = value;
    notifyListeners();
  }

  void setEditable4Value(int index, String value) {
    editableColumn4[index] = value;
    notifyListeners();
  }

  void setScore(int index, String value) {
    scores[index] = value;
    notifyListeners();
  }

  void setNote(int index, String value) {
    notes[index] = value;
    notifyListeners();
  }

  void setCoordinatorScore(String value) {
    coordinatorScore = value;
    notifyListeners();
  }

  void setHeadScore(String value) {
    headScore = value;
    notifyListeners();
  }

  void setExaminerCollegeScore(String value) {
    examinerCollegeScore = value;
    notifyListeners();
  }

  void setIsExaminer(bool value) {
    isExaminer = value;
    updateArraySizes(); // تحديث حجم المصفوفات عند تغيير نوع المستخدم
    notifyListeners();
  }

  // دالة تحويل الدرجة من 500 إلى 25
  double convertTo25(int score, {int total = 500}) {
    return (score / total) * 25;
  }

  Future<Uint8List> generatePdf({
    required String supervisorUsername,
    required List<String> studentNames,
    required String projectTitle,
    required String evaluationType,
  }) async {
    final pdfDoc = pw.Document();

    // حساب مجموع الدرجات المدخلة
    int totalScore = 0;
    for (var s in scores) {
      if (s.isNotEmpty) {
        totalScore += int.tryParse(s) ?? 0;
      }
    }
    double convertedTotal = convertTo25(totalScore);
    double convertedFull = convertTo25(500);

    // استخدم البنود حسب نوع المستخدم
    final items = currentEvaluationItems;

    pdfDoc.addPage(
      pw.Page(
        pageFormat: pdf.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Evaluation Form', style: pw.TextStyle(fontSize: 22)),
              pw.SizedBox(height: 16),
              pw.Text('Project Title: $projectTitle'),
              pw.Text('Student Names: ${studentNames.join(', ')}'),
              pw.Text('Supervisor: $supervisorUsername'),
              pw.Text('Evaluation Type: $evaluationType'),
              pw.SizedBox(height: 16),
              // جدول صغير في الأعلى:
              isExaminer
                  ? pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('College Score',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                examinerCollegeScore.isNotEmpty
                                    ? examinerCollegeScore
                                    : '-',
                                style: pw.TextStyle(fontSize: 16)),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text('Total',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                examinerCollegeScore.isNotEmpty
                                    ? '${examinerCollegeScore} / ${convertTo25(int.tryParse(examinerCollegeScore) ?? 0).toStringAsFixed(2)}'
                                    : '-',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ],
                    )
                  : pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('Project Coordinator Score',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                coordinatorScore.isNotEmpty
                                    ? coordinatorScore
                                    : '-',
                                style: pw.TextStyle(fontSize: 16)),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text('Department Head Score',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(headScore.isNotEmpty ? headScore : '-',
                                style: pw.TextStyle(fontSize: 16)),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text('Total',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(_getCoordinatorHeadTotal(),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
              pw.SizedBox(height: 16),
              // جدول التقييم الرئيسي:
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Item',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Max Score',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Score',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Notes',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  for (var i = 0; i < items.length; i++)
                    pw.TableRow(
                      children: [
                        pw.Text(items[i].detail),
                        pw.Text(items[i].maxScore.toString()),
                        pw.Text((scores.length > i && scores[i].isNotEmpty)
                            ? scores[i]
                            : '-'),
                        pw.Text((notes.length > i && notes[i].isNotEmpty)
                            ? notes[i]
                            : '-'),
                      ],
                    ),
                  // صف المجموع الكامل
                  pw.TableRow(
                    children: [
                      pw.Text('Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('500'),
                      pw.Text(
                          '$totalScore / ${convertTo25(totalScore).toStringAsFixed(2)}'),
                      pw.Text('-'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text('Table built, rows: ${items.length}',
                  style: pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );
    return pdfDoc.save();
  }

  Future<void> uploadPdf(Uint8List uint8listFile, int project) async {
    try {
      File tempFile = await createTemporaryFile(uint8listFile);
      final fileResponse = await FileService().uploadFile(tempFile);

      String? link;
      if (fileResponse != null) {
        link = fileResponse.data.downloadPage; // Use null-aware operator
        print('File uploaded: $link');
      } else {
        print('File upload failed.');
      }

      patchProject(
        id: project,
        teacher: 0,
        title: null,
        image: link,
        progression: null,
        deliveryDate: "",
        mainSuggestion: 0,
      );
    } catch (error) {
      print('Error uploading PDF: $error');
    }
    createTemporaryFile(uint8listFile).then((File file) {
      // Temporary file creation is complete
      // You can now use the 'file' object
    }).catchError((error) {
      // An error occurred during the temporary file creation process
      print('Error creating temporary file: $error');
    });
  }

  Future<void> uploadPdfFirstGrading(
      Uint8List uint8listFile, ProjectDetail project) async {
    try {
      File tempFile = await createTemporaryFile(uint8listFile);
      final fileResponse = await FileService().uploadFile(tempFile);

      String? link;
      if (fileResponse != null) {
        link = fileResponse.data.downloadPage;
        print('File uploaded: $link');
      } else {
        print('File upload failed.');
      }

      patchProject(
          id: project.id,
          title: project.title,
          image: project.image,
          teacher: 0,
          progression: null,
          deliveryDate: "",
          mainSuggestion: 0,
          firstGrading: null, // This should be set by the caller
          pdfExaminer1: link); // Add PDF link for examiner 1
    } catch (error) {
      print('Error uploading PDF: $error');
    }
  }

  Future<void> uploadPdfSecondGrading(
      Uint8List uint8listFile, ProjectDetail project) async {
    try {
      File tempFile = await createTemporaryFile(uint8listFile);
      final fileResponse = await FileService().uploadFile(tempFile);

      String? link;
      if (fileResponse != null) {
        link = fileResponse.data.downloadPage;
        print('File uploaded: $link');
      } else {
        print('File upload failed.');
      }

      patchProject(
          id: project.id,
          title: project.title,
          image: project.image,
          teacher: 0,
          progression: null,
          deliveryDate: "",
          mainSuggestion: 0,
          secondGrading: null, // This should be set by the caller
          pdfExaminer2: link); // Add PDF link for examiner 2
    } catch (error) {
      print('Error uploading PDF: $error');
    }
  }

  Future<void> uploadPdfTeacherGrading(
      Uint8List uint8listFile, ProjectDetail project) async {
    try {
      File tempFile = await createTemporaryFile(uint8listFile);
      final fileResponse = await FileService().uploadFile(tempFile);

      String? link;
      if (fileResponse != null) {
        link = fileResponse.data.downloadPage;
        print('File uploaded: $link');
      } else {
        print('File upload failed.');
      }

      patchProject(
          id: project.id,
          title: project.title,
          image: project.image,
          teacher: 0,
          progression: null,
          deliveryDate: "",
          mainSuggestion: 0,
          supervisorGrade: null, // This should be set by the caller
          pdfSupervisor: link); // Add PDF link for supervisor
    } catch (error) {
      print('Error uploading PDF: $error');
    }
  }

  Future<String?> saveAndUploadPdf({
    required String supervisorUsername,
    required String studentName,
    required String projectTitle,
    required String evaluationType,
    required int projectId,
  }) async {
    try {
      print('supervisorUsername: $supervisorUsername');
      print('studentName: $studentName');
      print('projectTitle: $projectTitle');
      print('evaluationType: $evaluationType');
      print('scores: $scores');
      print('notes: $notes');
      final pdfBytes = await generatePdf(
        supervisorUsername: supervisorUsername,
        studentNames: [studentName],
        projectTitle: projectTitle,
        evaluationType: evaluationType,
      );
      final tempFile = await createTemporaryFile(pdfBytes);
      final fileResponse = await FileService().uploadFile(tempFile);
      if (fileResponse != null) {
        // محاولة الحصول على رابط مباشر للملف
        String? pdfUrl;

        if (fileResponse.data.fileId != null) {
          // محاولة الحصول على رابط مباشر باستخدام fileId
          final directLink =
              await FileService().fetchDirectLink(fileResponse.data.fileId!);
          if (directLink != null && directLink.data.isNotEmpty) {
            pdfUrl = directLink.data.first.directLink;
            print('Direct PDF URL obtained: $pdfUrl');
          }
        }

        // إذا لم نحصل على رابط مباشر، استخدم downloadPage
        if (pdfUrl == null || pdfUrl.isEmpty) {
          pdfUrl = fileResponse.data.downloadPage;
          print('Using download page URL: $pdfUrl');
        }

        print('PDF uploaded successfully. Final URL: $pdfUrl');

        // حفظ رابط PDF في المشروع
        await patchProject(
          id: projectId,
          teacher: 0,
          title: "",
          image: "",
          progression: null,
          deliveryDate: "",
          mainSuggestion: 0,
          pdfLink: pdfUrl, // Save the PDF URL
        );
        return pdfUrl;
      } else {
        print('File upload failed - fileResponse is null');
        return null;
      }
    } catch (e) {
      print('Error saving and uploading PDF: $e');
      return null;
    }
  }

  // Helper function for total
  String _getCoordinatorHeadTotal() {
    int c = int.tryParse(coordinatorScore) ?? 0;
    int h = int.tryParse(headScore) ?? 0;
    return (c + h).toString();
  }

  /// رفع PDF ممتحن أول مع حفظ الدرجة الخام
  Future<String?> uploadExaminer1PdfAndScore({
    required Uint8List pdfBytes,
    required double rawScore, // الدرجة من 500
    required ProjectDetail project,
  }) async {
    File tempFile = await createTemporaryFile(Uint8List.fromList(pdfBytes));
    final fileResponse = await FileService().uploadFile(tempFile);
    String? pdfUrl = fileResponse?.data.downloadPage;
    await patchProject(
      id: project.id,
      teacher: project.teacher?.id ?? 0,
      progression: project.progression,
      deliveryDate: project.deliveryDate?.toIso8601String() ?? "",
      mainSuggestion: project.mainSuggestion?.id ?? 0,
      firstGrading: (rawScore / 20), // Use the correct field name
      pdfExaminer1: pdfUrl, // Add PDF link
    );

    // حساب وحفظ الدرجة النهائية
    await _calculateAndSaveFinalScore(project.id);
    return pdfUrl;
  }

  /// رفع PDF ممتحن ثاني مع حفظ الدرجة الخام
  Future<String?> uploadExaminer2PdfAndScore({
    required Uint8List pdfBytes,
    required double rawScore, // الدرجة من 500
    required ProjectDetail project,
  }) async {
    File tempFile = await createTemporaryFile(Uint8List.fromList(pdfBytes));
    final fileResponse = await FileService().uploadFile(tempFile);
    String? pdfUrl = fileResponse?.data.downloadPage;

    await patchProject(
      id: project.id,
      teacher: project.teacher?.id ?? 0,
      progression: project.progression,
      deliveryDate: project.deliveryDate?.toIso8601String() ?? "",
      mainSuggestion: project.mainSuggestion?.id ?? 0,
      secondGrading: (rawScore / 20), // Use the correct field name
      pdfExaminer2: pdfUrl, // Add PDF link
    );

    // حساب وحفظ الدرجة النهائية
    await _calculateAndSaveFinalScore(project.id);
    return pdfUrl;
  }

  /// رفع PDF المشرف مع حفظ الدرجات (المشرف، رئيس القسم، المنسق)
  Future<String?> uploadSupervisorPdfAndScores({
    required Uint8List pdfBytes,
    required double supervisorRaw, // من 500
    required double headScore, // من 5
    required double coordinatorScore, // من 5
    required ProjectDetail project,
  }) async {
    File tempFile = await createTemporaryFile(Uint8List.fromList(pdfBytes));
    final fileResponse = await FileService().uploadFile(tempFile);
    String? pdfUrl = fileResponse?.data.downloadPage;
    await patchProject(
      id: project.id,
      teacher: project.teacher?.id ?? 0,
      progression: project.progression,
      deliveryDate: project.deliveryDate?.toIso8601String() ?? "",
      mainSuggestion: project.mainSuggestion?.id ?? 0,
      supervisorGrade: (supervisorRaw / 12.5), // Use the correct field name
      departmentHeadGrade: headScore, // Use the correct field name
      coordinatorGrade: coordinatorScore, // Use the correct field name
      pdfSupervisor: pdfUrl, // Add PDF link for supervisor
      pdfHead: pdfUrl, // Add PDF link for head
      pdfCoordinator: pdfUrl, // Add PDF link for coordinator
      finalScore: null, // سيتم حسابها تلقائياً
    );

    // حساب وحفظ الدرجة النهائية
    await _calculateAndSaveFinalScore(project.id);
    return pdfUrl;
  }

  /// دالة لحساب الدرجة النهائية الموزونة
  double? _calculateWeightedFinalScore(Project project) {
    // حساب الدرجات المحولة حسب النظام الجديد
    double? supervisorScore = project.supervisorGrade != null
        ? (project.supervisorGrade! / 500) * 40
        : null;
    double? examiner1Score = project.firstGrading != null
        ? (project.firstGrading! / 500) * 25
        : null;
    double? examiner2Score = project.secondGrading != null
        ? (project.secondGrading! / 500) * 25
        : null;
    double? headScore = project.departmentHeadGrade; // من 5
    double? coordinatorScore = project.coordinatorGrade; // من 5

    // التحقق من الشروط المطلوبة
    bool hasSupervisor = supervisorScore != null;
    bool hasExaminer1 = examiner1Score != null;
    bool hasExaminer2 = examiner2Score != null;

    if (!hasSupervisor || (!hasExaminer1 && !hasExaminer2)) {
      return null; // لا يمكن حساب الدرجة النهائية
    }

    // جمع جميع الدرجات المتاحة
    List<double> availableScores = [];
    if (supervisorScore != null) availableScores.add(supervisorScore);
    if (examiner1Score != null) availableScores.add(examiner1Score);
    if (examiner2Score != null) availableScores.add(examiner2Score);
    if (headScore != null) availableScores.add(headScore);
    if (coordinatorScore != null) availableScores.add(coordinatorScore);

    if (availableScores.isEmpty) {
      return null;
    }

    // حساب الدرجة النهائية: مجموع جميع الدرجات مقسوم على عدد المقيمين × 100
    double totalScore = availableScores.reduce((a, b) => a + b);
    double averageScore = totalScore / availableScores.length;

    // تحويل الدرجة إلى مقياس من 100
    return (averageScore / 100) * 100;
  }

  /// دالة خاصة لحساب وحفظ الدرجة النهائية
  Future<void> _calculateAndSaveFinalScore(int projectId) async {
    try {
      // جلب بيانات المشروع المحدثة
      final projectResponse = await http.get(
        Uri.parse("${InternetService.baseUrl}/project/$projectId/"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (projectResponse.statusCode == 200) {
        final projectData = jsonDecode(projectResponse.body);
        final project = Project.fromJson(projectData);

        // حساب الدرجة النهائية باستخدام النظام الجديد
        double? finalScore = _calculateWeightedFinalScore(project);

        if (finalScore != null) {
          // حفظ الدرجة النهائية
          await saveFinalScore(projectId, finalScore);
          print('Final score calculated and saved: $finalScore');
        } else {
          print(
              'Cannot calculate final score yet - insufficient grades available');
        }
      }
    } catch (e) {
      print('Error calculating final score: $e');
    }
  }

  /// دالة لحفظ الدرجة النهائية
  Future<void> saveFinalScore(int projectId, double finalScore) async {
    try {
      await patchProject(
        id: projectId,
        teacher: 0,
        title: "",
        image: "",
        progression: null,
        deliveryDate: "",
        mainSuggestion: 0,
        finalScore: finalScore,
      );
      print('Final score saved successfully: $finalScore');
    } catch (e) {
      print('Error saving final score: $e');
    }
  }
}

Future<String> extractTextFromPdf(String filePath) async {
  final file = File(filePath);
  final bytes = await file.readAsBytes();
  final document = sfp.PdfDocument(inputBytes: bytes);
  // String text = PdfTextExtractor(document).extractText(); // Removed: pdf_text package does not exist
  document.dispose();
  return ""; // Return empty string as pdf_text is removed
}

Future<void> pickExtractAndUploadPdf({
  required int projectId,
  required String
      role, // 'examiner1', 'examiner2', 'supervisor', 'head', 'coordinator'
  required BuildContext context,
}) async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
  if (result != null && result.files.single.path != null) {
    final filePath = result.files.single.path!;

    try {
      // استخراج النص من PDF باستخدام syncfusion
      String text = await extractTextFromPdf(filePath);

      RegExp reg = RegExp(r"الدرجة\s*:? 0*(\d+)");
      final match = reg.firstMatch(text);
      if (match == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("لم يتم العثور على الدرجة في الملف")),
        );
        return;
      }
      double grade = double.parse(match.group(1)!);

      // رفع الملف باستخدام FileService
      final file = File(filePath);
      final fileResponse = await FileService().uploadFile(file);

      if (fileResponse != null) {
        String? pdfUrl = fileResponse.data.downloadPage;

        // تحديث المشروع حسب نوع الدور
        switch (role) {
          case 'examiner1':
            await patchProject(
              id: projectId,
              teacher: 0,
              title: "",
              image: "",
              progression: null,
              deliveryDate: "",
              mainSuggestion: 0,
              firstGrading: grade,
              pdfExaminer1: pdfUrl,
            );
            break;
          case 'examiner2':
            await patchProject(
              id: projectId,
              teacher: 0,
              title: "",
              image: "",
              progression: null,
              deliveryDate: "",
              mainSuggestion: 0,
              secondGrading: grade,
              pdfExaminer2: pdfUrl,
            );
            break;
          case 'supervisor':
            await patchProject(
              id: projectId,
              teacher: 0,
              title: "",
              image: "",
              progression: null,
              deliveryDate: "",
              mainSuggestion: 0,
              supervisorGrade: grade,
              pdfSupervisor: pdfUrl,
            );
            break;
          case 'head':
            await patchProject(
              id: projectId,
              teacher: 0,
              title: "",
              image: "",
              progression: null,
              deliveryDate: "",
              mainSuggestion: 0,
              departmentHeadGrade: grade,
              pdfHead: pdfUrl,
            );
            break;
          case 'coordinator':
            await patchProject(
              id: projectId,
              teacher: 0,
              title: "",
              image: "",
              progression: null,
              deliveryDate: "",
              mainSuggestion: 0,
              coordinatorGrade: grade,
              pdfCoordinator: pdfUrl,
            );
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم رفع الملف وحفظ الدرجة بنجاح")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل في رفع الملف")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في معالجة الملف: $e")),
      );
    }
  }
}
