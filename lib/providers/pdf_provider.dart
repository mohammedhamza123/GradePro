import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gradpro/models/project_details_list.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pages/widgets/widget_pdf.dart';
import '../services/file_services.dart';
import '../services/models_services.dart'; // Add this import

class EvaluationItem {
  final String section;
  final String detail;
  final int maxScore;
  EvaluationItem({required this.section, required this.detail, required this.maxScore});
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
    EvaluationItem(section: 'Teamwork', detail: 'Meetings and Sessions', maxScore: 10),
    EvaluationItem(section: 'Teamwork', detail: 'Attendance and Absence', maxScore: 10),
    EvaluationItem(section: 'Teamwork', detail: 'Commitment to Deadlines', maxScore: 10),
    EvaluationItem(section: 'Teamwork', detail: 'Contribution and Interaction', maxScore: 20),
    EvaluationItem(section: 'Relations & Communication', detail: 'Quality of Relations', maxScore: 10),
    EvaluationItem(section: 'Relations & Communication', detail: 'Enthusiasm for Work', maxScore: 10),
    EvaluationItem(section: 'Relations & Communication', detail: 'Communication', maxScore: 10),
    EvaluationItem(section: 'Relations & Communication', detail: 'Leadership', maxScore: 10),
    EvaluationItem(section: 'Project Analysis', detail: 'Problem to Solve', maxScore: 10),
    EvaluationItem(section: 'Project Analysis', detail: 'Literature Review and Case Study', maxScore: 10),
    EvaluationItem(section: 'Project Analysis', detail: 'Project Scope and Boundaries', maxScore: 10),
    EvaluationItem(section: 'Project Analysis', detail: 'Objectives and Benefits', maxScore: 10),
    EvaluationItem(section: 'Project Analysis', detail: 'Methodology', maxScore: 20),
    EvaluationItem(section: 'System Design', detail: 'Architecture Design', maxScore: 20),
    EvaluationItem(section: 'System Design', detail: 'Interfaces Design', maxScore: 20),
    EvaluationItem(section: 'System Design', detail: 'Database Design (Persistence)', maxScore: 20),
    EvaluationItem(section: 'System Design', detail: 'Algorithms Design', maxScore: 20),
    EvaluationItem(section: 'System Design', detail: 'Safety & Security', maxScore: 20),
    EvaluationItem(section: 'System Development', detail: 'Quality Plan', maxScore: 20),
    EvaluationItem(section: 'System Development', detail: 'Coding and Programming', maxScore: 20),
    EvaluationItem(section: 'System Development', detail: 'Testing and Test Cases', maxScore: 20),
    EvaluationItem(section: 'Presentation & Performance', detail: 'Presentation', maxScore: 20),
    EvaluationItem(section: 'Presentation & Performance', detail: 'Participation', maxScore: 20),
    EvaluationItem(section: 'Presentation & Performance', detail: 'Performance', maxScore: 20),
    EvaluationItem(section: 'Presentation & Performance', detail: 'Good Use of Tools', maxScore: 20),
    EvaluationItem(section: 'Final Appearance', detail: 'Appearance', maxScore: 20),
    EvaluationItem(section: 'Final Appearance', detail: 'Perfection', maxScore: 20),
    EvaluationItem(section: 'Final Appearance', detail: 'Quality', maxScore: 20),
    EvaluationItem(section: 'Final Appearance', detail: 'Good Use of Tools', maxScore: 20),
    EvaluationItem(section: 'Final Appearance', detail: 'Arabic Language', maxScore: 20),
  ];

  // بنود التقييم للممتحن (Examiner) بالعربي كما في الصورة
  List<EvaluationItem> examinerEvaluationItems = [
    EvaluationItem(section: 'Presentation & Seminar', detail: 'Commitment to Deadlines', maxScore: 20),
    EvaluationItem(section: 'Presentation & Seminar', detail: 'Contribution and Interaction', maxScore: 20),
    EvaluationItem(section: 'Presentation & Seminar', detail: 'Presentation Skills', maxScore: 30),
    EvaluationItem(section: 'Presentation & Seminar', detail: 'Clarity and Logical Sequence', maxScore: 30),
    EvaluationItem(section: 'Presentation & Seminar', detail: 'Use of Tools', maxScore: 20),
    EvaluationItem(section: 'Presentation & Seminar', detail: 'Answering Questions', maxScore: 30),
    EvaluationItem(section: 'Project Understanding', detail: 'Problem to Solve', maxScore: 20),
    EvaluationItem(section: 'Project Understanding', detail: 'Literature Review and Case Study', maxScore: 20),
    EvaluationItem(section: 'Project Understanding', detail: 'Project Scope and Boundaries', maxScore: 20),
    EvaluationItem(section: 'Project Understanding', detail: 'Objectives and Benefits', maxScore: 20),
    EvaluationItem(section: 'Project Understanding', detail: 'Methodology', maxScore: 20),
    EvaluationItem(section: 'Project Design', detail: 'Architecture Design', maxScore: 30),
    EvaluationItem(section: 'Project Design', detail: 'Interfaces Design', maxScore: 30),
    EvaluationItem(section: 'Project Design', detail: 'Database Design (Persistence)', maxScore: 30),
    EvaluationItem(section: 'Project Design', detail: 'Algorithms Design', maxScore: 30),
    EvaluationItem(section: 'Project Design', detail: 'Safety & Security', maxScore: 30),
    EvaluationItem(section: 'Report', detail: 'Appearance', maxScore: 20),
    EvaluationItem(section: 'Report', detail: 'Perfection', maxScore: 20),
    EvaluationItem(section: 'Report', detail: 'Quality', maxScore: 20),
    EvaluationItem(section: 'Report', detail: 'Good Use of Tools', maxScore: 20),
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
    final targetSize = isExaminer ? examinerEvaluationItems.length : evaluationItems.length;
    
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
    required String studentName,
    required String projectTitle,
    required String evaluationType,
  }) async {
    final pdf = pw.Document();

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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Evaluation Form', style: pw.TextStyle(fontSize: 22)),
              pw.SizedBox(height: 16),
              pw.Text('Project Title: $projectTitle'),
              pw.Text('Student Name: $studentName'),
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
                            pw.Text('College Score', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(examinerCollegeScore.isNotEmpty ? examinerCollegeScore : '-', style: pw.TextStyle(fontSize: 16)),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(examinerCollegeScore.isNotEmpty ? '${examinerCollegeScore} / ${convertTo25(int.tryParse(examinerCollegeScore) ?? 0).toStringAsFixed(2)}' : '-', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ],
                    )
                  : pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('Project Coordinator Score', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(coordinatorScore.isNotEmpty ? coordinatorScore : '-', style: pw.TextStyle(fontSize: 16)),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text('Department Head Score', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(headScore.isNotEmpty ? headScore : '-', style: pw.TextStyle(fontSize: 16)),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(_getCoordinatorHeadTotal(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                      pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Max Score', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Score', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  for (var i = 0; i < items.length; i++)
                    pw.TableRow(
                      children: [
                        pw.Text(items[i].detail),
                        pw.Text(items[i].maxScore.toString()),
                        pw.Text((scores.length > i && scores[i].isNotEmpty) ? scores[i] : '-'),
                        pw.Text((notes.length > i && notes[i].isNotEmpty) ? notes[i] : '-'),
                      ],
                    ),
                  // صف المجموع الكامل
                  pw.TableRow(
                    children: [
                      pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('500'),
                      pw.Text('$totalScore / ${convertTo25(totalScore).toStringAsFixed(2)}'),
                      pw.Text('-'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text('Table built, rows: ${items.length}', style: pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<File> createTemporaryFile(Uint8List uint8List) async {
    // Create a temporary directory
    Directory tempDir = await Directory.systemTemp.createTemp('temp_directory');

    // Generate a unique file name
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Create a temporary file within the temporary directory
    File tempFile = File('${tempDir.path}/$fileName');

    // Write the Uint8List data to the temporary file
    await tempFile.writeAsBytes(uint8List);

    return tempFile;
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
          firstGrading: link);
    } catch (error) {
      print('Error uploading PDF: $error');
    }
  }

  Future<void> uploadPdfSecondGrading(
      Uint8List uint8listFile, ProjectDetail project) async {
    // final String? link =
    //     await _storageService.uploadPdfFromUint8List(uint8listFile);
    // patchProject(
    //     id: project.id,
    //     title: project.title,
    //     image: project.image,
    //     teacher: 0,
    //     progression: null,
    //     deliveryDate: "",
    //     mainSuggestion: 0,
    //     secondGrading: link);
  }

  Future<void> uploadPdfTeacherGrading(
      Uint8List uint8listFile, ProjectDetail project) async {
    // final String? link =
    //     await _storageService.uploadPdfFromUint8List(uint8listFile);
    // patchProject(
    //     id: project.id,
    //     title: project.title,
    //     image: project.image,
    //     teacher: 0,
    //     progression: null,
    //     deliveryDate: "",
    //     mainSuggestion: 0,
    //     teacherGrading: link);
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
        studentName: studentName,
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
          final directLink = await FileService().fetchDirectLink(fileResponse.data.fileId!);
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
          teacherGrading: pdfUrl,
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
}
