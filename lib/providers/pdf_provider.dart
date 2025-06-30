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

class PdfProvider extends ChangeNotifier {
  // final PdfStorageService _storageService = PdfStorageService();
  List<String> header = [
    'المعيار',
    'الدرجة العظمي',
    'الطالب الاول',
    'الطالب الثاني'
  ];
  List<String> dataColumn1 = [
    'فكرة المشروع',
    'مطابقة الوثيقة لموضوع المشروع',
    'شمولية الوثيقة لكافة جوانب الموضوع',
    'التحليل و التصميم',
    'البناء و البرمجة',
    'إستخدام تقنيات جديدة',
    'الختبار وتشغيل النظام',
    'ادة العرض التقديمي وتناسبه مع الوقت المحدد',
    'لقاء الطالب و قدرته على الإقناع',
    'إجابة السئلة',
    'حسن سلوك الطالب',
  ];
  List<String> dataColumn2 = [
    '2',
    '2',
    '3',
    '2',
    '2',
    '4',
    '2',
    '3',
    '3',
    '5',
    '2'
  ];
  List<String> editableColumn3 = List.generate(11, (index) => '');
  List<String> editableColumn4 = List.generate(11, (index) => '');

  bool isFileLoading = false;

  void setEditable3Value(int index, String value) {
    editableColumn3[index] = value;
    notifyListeners();
  }

  void setEditable4Value(int index, String value) {
    editableColumn4[index] = value;
    notifyListeners();
  }

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();
    var data = await rootBundle.load("fonts/Tajawal-Regular.ttf");
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return GradingTablePdf(header, dataColumn1, dataColumn2,
              editableColumn3, editableColumn4, data);
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
}
