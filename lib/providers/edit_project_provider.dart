import 'package:flutter/cupertino.dart';
import 'package:gradpro/models/project_details_list.dart';
import '../services/models_services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class AdminEditProjectProvider extends ChangeNotifier {
  ProjectDetail? _project;
  ProjectDetail? get project => _project;

  List<ProjectDetail> _projectList = [];
  List<ProjectDetail> _filteredProjectList = [];

  TextEditingController searchbarController = TextEditingController();

  List<ProjectDetail> get filterList => _filteredProjectList;

  List<ProjectDetail> get projectList => _projectList;

  String _error = "";

  final _formKey = GlobalKey<FormState>();

  GlobalKey<FormState> get formKey => _formKey;

  TextEditingController title = TextEditingController();
  TextEditingController mainSuggestion = TextEditingController();
  TextEditingController image = TextEditingController();
  TextEditingController deliveryDate = TextEditingController();
  TextEditingController progression = TextEditingController();

  bool _canEdit = true;
  bool _isLoading = false;

  bool get canEdit => _canEdit;

  bool get isLoading => _isLoading;

  String get error => _error;

  Future<void> updateProject() async {
    _isLoading = true;
    if (_project != null) {
      try {
        await patchProject(
          id: _project!.id,
          teacher: 0, // يمكن تعديل هذا حسب الحاجة
          title: title.text,
          image: image.text,
          progression: double.tryParse(progression.text),
          deliveryDate: deliveryDate.text,
          mainSuggestion: int.tryParse(mainSuggestion.text),
        );
        title.clear();
        mainSuggestion.clear();
        image.clear();
        deliveryDate.clear();
        progression.clear();
        _isLoading = false;
        _canEdit = false;
        _error = "";
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        if (_error.length > 150) {
          _error = _error.substring(0, 150);
        }
        _isLoading = false;
        _canEdit = false;
        notifyListeners();
      }
    }
  }

  // تحميل المشاريع مرة واحدة فقط
  Future<bool> loadProjects() async {
    if (_projectList.isNotEmpty) {
      // إذا كانت القائمة مليئة بالمشاريع بالفعل، لا نقوم بتحميلها مجددًا
      return true;
    }

    try {
      final data = await getProjectDetailsList();
      _projectList = data.datum;
      _filteredProjectList =
          List.from(_projectList); // حفظ نسخة من المشاريع لاستخدامها في الفلترة
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // إضافة دالة لتحديث المشاريع
  Future<bool> refreshProjects() async {
    try {
      final data = await getProjectDetailsList();
      _projectList = data.datum;
      _filteredProjectList =
          List.from(_projectList); // حفظ نسخة من المشاريع لاستخدامها في الفلترة
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void filterProjectList() {

    notifyListeners();
  }

  Future<void> deleteProject(int id, int index, bool isList) async {
    await delProject(id);
    if (isList) {
      _projectList.removeAt(index);
    } else {
      _filteredProjectList.removeAt(index);
    }
    notifyListeners();
  }

  Future<String?> getPdfLink() async {
    if (_project != null) {
      await loadProjects(); // نقوم بتحميل المشاريع فقط إذا لم تكن محملة مسبقًا
      return "ok";
    }
    return null;
  }

  void setProject(item) {
    _project = item;
    if (_project != null) {
      _error = "";
      title.text = _project!.title;
      progression.text = _project!.progression.toString();
      image.text = _project!.image;
      deliveryDate.text = _project!.deliveryDate?.year != null
          ? "${_project!.deliveryDate?.year}-${_project!.deliveryDate?.month}-${_project!.deliveryDate?.day}"
          : "";
      mainSuggestion.text = _project!.mainSuggestion?.id.toString() ?? "";
    } else {
      _isLoading = false;
    }
    notifyListeners();
  }

  void setDeliveryDate(DateTime date) {
    deliveryDate.text = "${date.year}-${date.month}-${date.day}";
    notifyListeners();
  }

  void onFromStateChanged() {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _canEdit = true;
      } else {
        _canEdit = false;
      }
    } else {
      _canEdit = false;
    }
    notifyListeners();
  }

  String? validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[\w.@+-]+$').hasMatch(value)) {
      return 'اسم المستخدم غير صالح';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[\w.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'هذا البريد غير صالح';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return null;
  }

  Future<bool> uploadGradePdf({
    required int projectId,
    required String
        role, // 'examiner1', 'examiner2', 'supervisor', 'head', 'coordinator'
    required double grade,
  }) async {
    // اختيار ملف PDF
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://your-backend-url/api/project/ $projectId/upload-grade/'),
      );
      request.fields['role'] = role;
      request.fields['grade'] = grade.toString();
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        // تم رفع الملف وحفظ الدرجة بنجاح
        return true;
      } else {
        // فشل في رفع الملف أو حفظ الدرجة
        return false;
      }
    }
    return false;
  }
}



// String? validateConfirmPassword(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return null;
  //   }
  //   if (value.length < 8) {
  //     return 'كلمة المرور قصيرة يجب ان تكون 8 احرف علي الاقل';
  //   }
  //   if (password.value.text != value) {
  //     return 'يرجي التاكيد من كلمة المرور غير مشابهه';
  //   }
  //   return null;
  // }


