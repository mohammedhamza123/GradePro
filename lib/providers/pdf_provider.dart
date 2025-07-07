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

  // بنود التقييم مطابقة للصورة
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

  // متغيرات الدرجات والملاحظات لكل بند
  List<String> scores = List.generate(30, (index) => '');
  List<String> notes = List.generate(30, (index) => '');

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

  // دالة تحويل الدرجة من 500 إلى 40
  double convertTo40(int score, {int total = 500}) {
    return (score / total) * 40;
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
    double convertedTotal = convertTo40(totalScore);
    double convertedFull = convertTo40(500);

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
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Item'),
                      pw.Text('Max Score'),
                      pw.Text('Score'),
                      pw.Text('Notes'),
                    ],
                  ),
                  for (var i = 0; i < evaluationItems.length; i++)
                    pw.TableRow(
                      children: [
                        pw.Text(evaluationItems[i].detail),
                        pw.Text(evaluationItems[i].maxScore.toString()),
                        pw.Text((scores.length > i && scores[i].isNotEmpty) ? scores[i] : '-'),
                        pw.Text((notes.length > i && notes[i].isNotEmpty) ? notes[i] : '-'),
                      ],
                    ),
                  // صف المجموع الكامل
                  pw.TableRow(
                    children: [
                      pw.Text('Full Total'),
                      pw.Text('500'),
                      pw.Text(convertedFull.toStringAsFixed(2)),
                      pw.Text('-'),
                    ],
                  ),
                  // صف مجموع الدرجات المدخلة
                  pw.TableRow(
                    children: [
                      pw.Text('Entered Total'),
                      pw.Text(totalScore.toString()),
                      pw.Text(convertedTotal.toStringAsFixed(2)),
                      pw.Text('-'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text('Table built, rows: ${evaluationItems.length}', style: pw.TextStyle(fontSize: 10)),
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
  }) async {
    try {
      // طباعة القيم المدخلة للتشخيص
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
        return fileResponse.data.downloadPage;
      } else {
        return null;
      }
    } catch (e) {
      print('Error saving and uploading PDF: $e');
      return null;
    }
  }
}
