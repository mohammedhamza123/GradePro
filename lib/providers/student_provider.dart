import 'package:flutter/material.dart';
import 'package:gradpro/models/requirement_list.dart';
import 'package:gradpro/models/suggestion_list.dart';
import 'package:gradpro/services/image_services.dart';
import 'package:gradpro/services/user_services.dart';

import '../models/important_date_list.dart';
import '../models/project_list.dart';
import '../services/models_services.dart';

class StudentProvider extends ChangeNotifier {
  final ImageService _imageService = ImageService();
  final UserService _userService = UserService();
  int _selectedIndex = 0;
  String _errorMessage = "";
  bool _isError = false;
  bool _newSuggestion = false;
  bool loadingSaveSuggestion = false;
  Suggestion? _selectedSuggestion;
  String _imageBase64 = "";
  String _suggestionUrl = "https://placehold.co/600x400.png";
  String _suggestionTitle = "";
  String _suggestionContent = "";
  String? onSaveSuggestionError;

  List<ImportantDate> _importantDates = [];
  List<Suggestion> _suggestionList = [];
  List<Project> _projectList = [];
  List<Requirement> _requirementList = [];

  int get selectedIndex => _selectedIndex;

  String get suggestionUrl => _suggestionUrl;

  String get errorMessage => _errorMessage;

  String get imageBase64 => _imageBase64;

  bool get isError => _isError;

  bool get newSuggestion => _newSuggestion;

  Suggestion? get selectedSuggestion => _selectedSuggestion;

  Future<List<ImportantDate>> get importantDates async => _loadImportantDates();

  List<Suggestion> get suggestionList => _suggestionList;

  List<Project> get projectList => _projectList;

  Project? _currentProject;

  Project? get currentProject => _currentProject;

  List<Requirement> get requirementList => _requirementList;

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> onItemTapped(int index) async {
    _selectedIndex = index;
    switch (_selectedIndex) {
      case 0:
        _loadImportantDates();
      case 1:
        _loadSuggestions();
      case 2:
        _loadProjects();
    }
    notifyListeners();
  }

  Future<void> retry() async {
    await _loadImportantDates();
    await _loadSuggestions();
    await _loadProjects();
    notifyListeners();
  }

  Future<Suggestion?> getCurrentProject() async {
    final project = await _userService.project;
    _currentProject = project;
    if (_suggestionList.isNotEmpty) {
      if (_currentProject != null) {
        if (_currentProject?.mainSuggestion != null) {
          final index = _suggestionList.indexWhere(
              (element) => element.id == _currentProject!.mainSuggestion!);
          _selectedSuggestion = _suggestionList[index];
          if (_selectedSuggestion != null) {
            return _selectedSuggestion;
          }
        }
      }
    }
    return null;
  }

  Future<List<ImportantDate>> _loadImportantDates() async {
    _isError = false;
    try {
      final ImportantDateList data = await getImportantDatesList();
      _importantDates = data.importantDate;
      return data.importantDate;
    } catch (e) {
      setErrorMessage(e.toString());
      _isError = true;
    }
    notifyListeners();
    return [];
  }

  Future<void> _loadSuggestions() async {
    _isError = false;
    try {
      final data = await getSuggestionList();
      final requirements = await getRequirementList();
      _requirementList = requirements.requirement;
      if (_selectedSuggestion != null) {
        _requirementList = _requirementList
            .where((element) => element.suggestion == _selectedSuggestion!.id)
            .toList();
      }
      _suggestionList = data.suggestion;
    } catch (e) {
      setErrorMessage(e.toString());
      _isError = true;
    }
    notifyListeners();
  }

  Future<void> _loadProjects() async {
    _isError = false;
    try {
      final data = await getProjectList();
      _projectList = data.project;
    } catch (e) {
      setErrorMessage(e.toString());
      _isError = true;
    }
    notifyListeners();
  }

  void setSelectedSuggestion(int index) {
    _selectedSuggestion = _suggestionList[index];
    _requirementList = [];
    _loadSuggestions();
    notifyListeners();
  }

  void createRequirement(String content) async {
    if (_selectedSuggestion != null) {
      final requirement =
          await postRequirement(_selectedSuggestion!.id, content);
      _requirementList.add(requirement);
      getCurrentProject();
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
    notifyListeners();
  }

  void setNewSuggestionTitle(String value) {
    _suggestionTitle = value;
  }

  void setNewSuggestionContent(String value) {
    _suggestionContent = value;
  }

  Future<void> createProject() async {
    onSaveSuggestionError = null;
    final student = await _userService.student;
    if (student != null) {
      if (_currentProject == null) {
        Project project = Project(
            image: "Empty",
            progression: 0,
            id: 0,
            title: _suggestionTitle,
            mainSuggestion: null,
            deliveryDate: null,
            teacher: null);
        project = await postProject(project);
        _currentProject = project;
        await patchStudent(student.id, null, _currentProject!.id, null);
        project = await getProject(project.id);
        await createSuggestion(project);
      }else{
        await createSuggestion(_currentProject!);
      }
    }
    loadingSaveSuggestion = false;
    onItemTapped(selectedIndex);
    notifyListeners();
  }

  Future<void> createSuggestion(Project project) async {
    Suggestion suggestion = Suggestion(
        project: project.id,
        id: 0,
        content: _suggestionContent,
        status: "w",
        title: _suggestionTitle,
        image: _suggestionUrl);
    suggestion = await postSuggestion(suggestion);
    await patchProject(
        id: project.id,
        teacher: 0,
        title: suggestion.title,
        image: "Well we got nothing that we can do",
        progression: 0,
        deliveryDate: "",
        mainSuggestion: suggestion.id);
    _selectedSuggestion = suggestion;
  }

  void deleteSuggestion() {
    delSuggestion(_selectedSuggestion!.id);
    onItemTapped(1);
    _selectedSuggestion = null;
    notifyListeners();
  }

  void deleteRequirement(int index) {
    delRequirement(_requirementList[index].id);
    _requirementList.removeAt(index);
    getCurrentProject();
    notifyListeners();
  }

  Future<void> editRequirement(int id, Requirement requirement) async {
    await patchRequirement(id, requirement.name, requirement.status, null);
    getCurrentProject();
    _loadSuggestions();
  }
}
