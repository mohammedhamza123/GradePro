import 'package:flutter/cupertino.dart';
import 'package:gradpro/models/project_list.dart';
import 'package:gradpro/models/teacher_details_list.dart';
import 'package:gradpro/services/models_services.dart';
import 'package:gradpro/services/internet_services.dart';

import '../models/project_details_list.dart';
import '../models/student_details_list.dart';
import '../models/suggestion_list.dart';

class AdminProjectProvider extends ChangeNotifier {
  bool _done = false;
  bool _refreshing = false;
  List<ProjectDetail> _filteredProjectList = [];
  List<StudentDetail> _studentsToAdd = [];
  ProjectDetail? _currentProject;
  TeacherDetail? _teacherDetail;

  bool _isProjectsLoaded = false;
  bool _isStudentsLoaded = false;
  bool _isTeacherLoaded = false;

  List<ProjectDetail> _projectList = [];
  List<StudentDetail> _studentList = [];
  List<TeacherDetail> _teacherList = [];

  TextEditingController searchbarController = TextEditingController();

  bool _isProjectSelected = false;

  bool get isProjectSelected => _isProjectSelected;
  bool get done => _done;
  bool get refreshing => _refreshing;
  // Getters for current project, students to add, teacher to set
  ProjectDetail? get currentProject => _currentProject;
  List<StudentDetail> get studentsToAdd => _studentsToAdd;
  TeacherDetail? get teacherToSet => _teacherDetail;

  // Getter for filtered project list
  List<ProjectDetail> get projectList => _projectList;
  List<ProjectDetail> get filteredProjectList => _filteredProjectList;

  // Getter for filtered student list
  List<StudentDetail> get filterList => _filteredStudentList;
  List<StudentDetail> get studentList => _studentList;

  // Getter for filtered teacher list
  List<TeacherDetail> get filteredTeacherList => _filteredTeacherList;
  List<TeacherDetail> get teacherList => _teacherList;

  Future<void> createProject(String title) async {
    Project project = Project(
        image: "https://placehold.co/600x400.png",
        progression: 0.0,
        id: 0,
        title: title,
        mainSuggestion: null,
        deliveryDate: null,
        teacher: null);
    try {
      await postProject(project);
      _done = true;
      notifyListeners();
    } catch (e) {
      _done = false;
      notifyListeners();
    }
  }

  // Load projects once
  Future<bool> loadProjects() async {
    if (_isProjectsLoaded) return true; // Don't load again if already loaded
    try {
      final data = await getProjectDetailsList();
      _projectList = data.datum;
      _isProjectsLoaded = true;
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
      _isProjectsLoaded = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Filter projects locally after loading them
  void filterProjectsList() {
    final text = searchbarController.text.toLowerCase();
    if (text.isEmpty) {
      _filteredProjectList = _projectList;
    } else {
      _filteredProjectList = _projectList
          .where((e) => e.title.toLowerCase().contains(text))
          .toList();
    }
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

  void setIsProjectSelected(bool value) {
    _isProjectSelected = value;
    notifyListeners();
  }

  List<StudentDetail> _filteredStudentList = [];

  Future<List<StudentDetail>> loadStudents({bool checkChanges = true}) async {
    if (_isStudentsLoaded)
      return _studentList; // Don't load again if already loaded

    // Check if user is authenticated before making API call
    final InternetService services = InternetService();
    if (!services.isAuthorized()) {
      // Return empty list if not authenticated
      _studentList = [];
      _isStudentsLoaded = true;
      notifyListeners();
      return _studentList;
    }

    try {
      final data = await getStudentDetailsList();
      _studentList = data.studentDetails;
      _isStudentsLoaded = true;
      notifyListeners();
      return _studentList;
    } catch (e) {
      // If API call fails, return empty list
      _studentList = [];
      _isStudentsLoaded = true;
      notifyListeners();
      return _studentList;
    }
  }

  // إضافة دالة لتحديث الطلبة
  Future<List<StudentDetail>> refreshStudents() async {
    try {
      final data = await getStudentDetailsList();
      _studentList = data.studentDetails;
      _isStudentsLoaded = true;
      notifyListeners();
      return _studentList;
    } catch (e) {
      return _studentList;
    }
  }

  // Filter students locally after loading them
  void filterStudentList() {
    final text = searchbarController.text.toLowerCase();
    if (text.isEmpty) {
      _filteredStudentList = _studentList;
    } else {
      _filteredStudentList = _studentList
          .where((e) =>
              e.user.firstName.toLowerCase().contains(text) ||
              e.user.lastName.toLowerCase().contains(text) ||
              e.user.username.toLowerCase().contains(text))
          .toList();
    }
    notifyListeners();
  }

  Future<List<StudentDetail>> loadFilteredStudentForProject(
      int projectId) async {
    if (_studentList.isEmpty) {
      // Check if user is authenticated before making API call
      final InternetService services = InternetService();
      if (!services.isAuthorized()) {
        return [];
      }

      try {
        final data = await getStudentDetailsList();
        _studentList = data.studentDetails;
      } catch (e) {
        return [];
      }
    }
    return _studentList.where((e) => e.project == projectId).toList();
  }

  // تعديل دالة إضافة طالب لتضيف طالب للقائمة
  void addStudentToSelection(StudentDetail student) {
    if (!_studentsToAdd.any((s) => s.id == student.id)) {
      _studentsToAdd.add(student);
      notifyListeners();
    }
  }

  // دالة لإزالة طالب من القائمة
  void removeStudentFromSelection(StudentDetail student) {
    _studentsToAdd.removeWhere((s) => s.id == student.id);
    notifyListeners();
  }

  // دالة للتحقق من وجود طالب في القائمة
  bool isStudentSelected(StudentDetail student) {
    return _studentsToAdd.any((s) => s.id == student.id);
  }

  // دالة لمسح جميع الطلاب المحددين
  void clearSelectedStudents() {
    _studentsToAdd.clear();
    notifyListeners();
  }

  void setCurrentProject(ProjectDetail? item) {
    if (_currentProject != item) {
      _currentProject = item;
      notifyListeners();
    }
  }

  // تعديل دالة إضافة الطلاب للمشروع لتجنب التعديل المتزامن
  Future<bool> addStudentsToProject() async {
    if (_studentsToAdd.isNotEmpty && currentProject != null) {
      bool allSuccess = true;
      // التكرار على نسخة من القائمة لتجنب التعديل المتزامن
      final studentsCopy = List<StudentDetail>.from(_studentsToAdd);
      for (StudentDetail student in studentsCopy) {
        if (student.project == null) {
          try {
            final data =
                await patchStudent(student.id, null, currentProject!.id, null);
            if (data.project == currentProject!.id) {
              student.project = currentProject!.id; // Update locally
            } else {
              allSuccess = false;
            }
          } catch (e) {
            allSuccess = false;
          }
        }
      }
      if (allSuccess) {
        notifyListeners();
      }
      return allSuccess;
    }
    return false;
  }

  // Load teachers once
  List<TeacherDetail> _filteredTeacherList = [];
  Future<List<TeacherDetail>> loadTeachers() async {
    if (_isTeacherLoaded)
      return _teacherList; // Don't load again if already loaded

    // Check if user is authenticated before making API call
    final InternetService services = InternetService();
    if (!services.isAuthorized()) {
      // Return empty list if not authenticated
      _teacherList = [];
      _isTeacherLoaded = true;
      notifyListeners();
      return _teacherList;
    }

    try {
      final data = await getTeacherDetailsList();
      _teacherList = data.teacher;
      _isTeacherLoaded = true;
      notifyListeners();
      return _teacherList;
    } catch (e) {
      // If API call fails, return empty list
      _teacherList = [];
      _isTeacherLoaded = true;
      notifyListeners();
      return _teacherList;
    }
  }

  // إضافة دالة لتحديث الأساتذة
  Future<List<TeacherDetail>> refreshTeachers() async {
    try {
      final data = await getTeacherDetailsList();
      _teacherList = data.teacher;
      _isTeacherLoaded = true;
      notifyListeners();
      return _teacherList;
    } catch (e) {
      return _teacherList;
    }
  }

  // Filter teachers locally after loading them
  void filterTeacherList() {
    final text = searchbarController.text.toLowerCase();
    if (text.isEmpty) {
      _filteredTeacherList = _teacherList;
    } else {
      _filteredTeacherList = _teacherList
          .where((e) =>
              e.user.firstName.toLowerCase().contains(text) ||
              e.user.lastName.toLowerCase().contains(text) ||
              e.user.username.toLowerCase().contains(text))
          .toList();
    }
    notifyListeners();
  }

  void setCurrentTeacher(TeacherDetail? item) {
    _teacherDetail = item;
    notifyListeners();
  }

  // Set teacher to project
  Future<bool> setTeacherToProject() async {
    if (teacherToSet != null && currentProject != null) {
      try {
        final data = await patchProject(
            id: currentProject!.id,
            teacher: teacherToSet!.id,
            mainSuggestion: 0,
            deliveryDate: "",
            title: currentProject!.title,
            image: currentProject!.image,
            progression: null);
        if (data.teacher == teacherToSet!.id) {
          return true;
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // Examiner state (similar to teacher)
  TeacherDetail? _examinerDetail;
  List<TeacherDetail> _filteredExaminerList = [];

  // Getter for current examiner
  TeacherDetail? get examinerToSet => _examinerDetail;
  List<TeacherDetail> get filteredExaminerList => _filteredExaminerList;

  // Filter examiners from teacher list (where isExaminer == true)
  void filterExaminerList() {
    final text = searchbarController.text.toLowerCase();
    final examiners = _teacherList.where((e) => e.isExaminer == true).toList();
    if (text.isEmpty) {
      _filteredExaminerList = examiners;
    } else {
      _filteredExaminerList = examiners
          .where((e) =>
              e.user.firstName.toLowerCase().contains(text) ||
              e.user.lastName.toLowerCase().contains(text) ||
              e.user.username.toLowerCase().contains(text))
          .toList();
    }
    notifyListeners();
  }

  // Set current examiner
  void setCurrentExaminer(TeacherDetail? item) {
    _examinerDetail = item;
    notifyListeners();
  }

  // Placeholder for assigning examiner to project (to be implemented by user)
  Future<bool> setExaminerToProject() async {
    if (examinerToSet != null && currentProject != null) {
      try {
        if (currentProject != null && examinerToSet != null) {
          _examinerDetail!.examinedProjects.add(currentProject!.id);
          await patchTeacher(
              examinerToSet!.id, null, null, _examinerDetail!.examinedProjects);
          return true;
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // Change suggestion status
  Future<void> changeSuggestionStatus(Suggestion s, String status) async {
    _refreshing = true;
    notifyListeners();
    await patchSuggestion(
        id: s.id, title: s.title, image: s.image, status: status);
    await refreshProjects();
    _refreshing = false;
    notifyListeners();
  }
}
