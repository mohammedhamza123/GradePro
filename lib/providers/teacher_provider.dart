import 'package:flutter/cupertino.dart';
import 'package:gradpro/models/requirement_list.dart';
import 'package:gradpro/services/image_services.dart';
import 'package:gradpro/services/user_services.dart';
import 'package:gradpro/services/internet_services.dart';

import '../models/important_date_list.dart';
import '../models/project_details_list.dart';
import '../models/student_details_list.dart';
import '../models/suggestion_list.dart';
import '../models/teacher_list.dart';
import '../models/user_list.dart';
import '../services/models_services.dart';

import 'package:flutter/material.dart';

class TeacherProvider extends ChangeNotifier {
  static final UserService _userService = UserService();
  static final ImageService _imageService = ImageService();
  int _selectedIndex = 0;
  bool _newSuggestion = false;
  List<ProjectDetail> _projectList = [];
  List<StudentDetail> _studentList = [];
  List<Suggestion> _suggestionList = [];
  List<Requirement> _requirementList = [];
  String _imageBase64 = "";
  String _suggestionUrl = "";
  String _suggestionContent = "";
  String _suggestionTitle = "";

  ProjectDetail? _currentProject;

  Suggestion? _selectedSuggestion;

  Teacher? _teacher;

  int get selectedIndex => _selectedIndex;

  bool get newSuggestion => _newSuggestion;

  String get suggestionUrl => _suggestionUrl;

  Suggestion? get selectedSuggestion => _selectedSuggestion;

  ProjectDetail? get currentProject => _currentProject;

  Teacher? get teacher => _teacher;

  Future<User?> get user async => await _userService.user;

  List<ProjectDetail> get teacherProjectList => setTeacherProjects();

  List<ProjectDetail> get projectList => _projectList;

  Future<List<ImportantDate>> get importantDates => _loadImportantDates();

  Future<List<Suggestion>> get suggestionList => _loadSuggestions();

  List<Requirement> get requirementList => _requirementList;

  Future<List<Requirement>> get fetchRequirement => loadRequirement();

  void onItemTapped(int index) {
    _selectedIndex = index;
    switch (_selectedIndex) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
    }
    notifyListeners();
  }

  Future<bool> loadTeacher() async {
    final user = await _userService.user;
    if (user != null) {
      _teacher = await getTeacher(user.id);
      return true;
    }
    return false;
  }

  Future<bool> loadProjects() async {
    final InternetService services = InternetService();
    if (!services.isAuthorized()) {
      return false;
    }
    
    try {
      final data = await getProjectDetailsList();
      _projectList = data.datum;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  List<ProjectDetail> setTeacherProjects() {
    if (_projectList.isNotEmpty && teacher != null) {
      if (teacher!.isExaminer) {
        // إذا كان ممتحن، أظهر المشاريع التي هو ممتحن لها
        return _projectList.where((element) =>
          (element.examiner1Raw != null && element.teacher?.id == teacher!.id) ||
          (element.examiner2Raw != null && element.teacher?.id == teacher!.id)
        ).toList();
      } else {
        // إذا كان مشرف، أظهر المشاريع التي هو مشرف عليها
        return _projectList.where((element) => element.teacher?.id == teacher!.id).toList();
      }
    } else {
      return [];
    }
  }

  Future<List<StudentDetail>> loadFilteredStudentForProject(
      int projectId) async {
    if (_studentList.isEmpty) {
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

  Future<List<ImportantDate>> _loadImportantDates() async {
    try {
      final ImportantDateList data = await getImportantDatesList();
      return data.importantDate;
    } catch (e) {}
    notifyListeners();
    return [];
  }

  Future<void> setCurrentProject(ProjectDetail item) async {
    _selectedSuggestion = null;
    _currentProject = item;
    if (_currentProject != null) {
      _selectedSuggestion = _currentProject!.mainSuggestion;
    }
    notifyListeners();
  }

  Future<List<Suggestion>> _loadSuggestions() async {
    try {
      final data = await getSuggestionList();
      _suggestionList = data.suggestion;
      return _suggestionList;
    } catch (e) {}
    return [];
  }

  Future<List<Requirement>> loadRequirement() async {
    try {
      final requirements = await getRequirementList();
      _requirementList = requirements.requirement;
      if (_selectedSuggestion != null) {
        _requirementList = _requirementList
            .where((element) => element.suggestion == _selectedSuggestion!.id)
            .toList();
      }
      return _requirementList;
    } catch (e) {}
    return [];
  }

  void createRequirement(String content) async {
    if (_selectedSuggestion != null) {
      final requirement =
          await postRequirement(_selectedSuggestion!.id, content);
      _requirementList.add(requirement);
      notifyListeners();
    }
  }

  void setNewSuggestion(bool val) {
    _newSuggestion = val;
    notifyListeners();
  }

  void setImageBase64(String image) {
    _imageBase64 = image;
    notifyListeners();
  }

  Future<void> uploadImage() async {
    final data = await _imageService.postImage(_imageBase64);
    _suggestionUrl = data.data.url;
  }

  void setNewSuggestionTitle(String value) {
    _suggestionTitle = value;
  }

  void setNewSuggestionContent(String value) {
    _suggestionContent = value;
  }

  Future<void> createSuggestion() async {
    if (currentProject != null) {
      final suggestion = Suggestion(
          project: currentProject!.id,
          id: 0,
          content: _suggestionContent,
          status: "w",
          title: _suggestionTitle,
          image: _suggestionUrl);
      await postSuggestion(suggestion);
    }
  }

  void deleteSuggestion() {
    delSuggestion(_selectedSuggestion!.id);
    onItemTapped(1);
    _selectedSuggestion = null;
  }

  void deleteRequirement(int index) {
    delRequirement(_requirementList[index].id);
    _requirementList.removeAt(index);
    notifyListeners();
  }

  Future<void> editRequirement(int id, Requirement requirement) async {
    await patchRequirement(id, requirement.name, requirement.status, null);
    _loadSuggestions();
  }
}
