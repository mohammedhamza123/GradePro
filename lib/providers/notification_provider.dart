import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_services.dart';
import '../models/student_list.dart';
import '../models/project_list.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<Student> _pendingStudents = [];
  List<Project> _pendingProjects = [];
  int _pendingStudentsCount = 0;
  int _pendingProjectsCount = 0;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Getters
  List<Student> get pendingStudents => _pendingStudents;
  List<Project> get pendingProjects => _pendingProjects;
  int get pendingStudentsCount => _pendingStudentsCount;
  int get pendingProjectsCount => _pendingProjectsCount;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  // Total pending count for badge
  int get totalPendingCount => _pendingStudentsCount + _pendingProjectsCount;
  
  // Initialize notifications
  Future<void> initializeNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Load initial data
      await loadPendingStudents();
      await loadPendingProjects();
      
      // Start real-time updates
      _startRealTimeUpdates();
      
      _isLoading = false;
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'خطأ في تحميل الإشعارات: $e';
      notifyListeners();
    }
  }
  
  // Load pending students
  Future<void> loadPendingStudents() async {
    try {
      final students = await _notificationService.getPendingStudents();
      _pendingStudents = students;
      _pendingStudentsCount = students.length;
      notifyListeners();
    } catch (e) {
      print('Error loading pending students: $e');
      _errorMessage = 'خطأ في تحميل طلبات الطلاب';
    }
  }
  
  // Load pending projects
  Future<void> loadPendingProjects() async {
    try {
      final projects = await _notificationService.getPendingProjects();
      _pendingProjects = projects;
      _pendingProjectsCount = projects.length;
      notifyListeners();
    } catch (e) {
      print('Error loading pending projects: $e');
      _errorMessage = 'خطأ في تحميل طلبات المشاريع';
    }
  }
  
  // Approve student
  Future<bool> approveStudent(int studentId) async {
    try {
      final success = await _notificationService.approveStudent(studentId);
      if (success) {
        // Remove from pending list
        _pendingStudents.removeWhere((student) => student.id == studentId);
        _pendingStudentsCount = _pendingStudents.length;
        notifyListeners();
        
        // Send real-time notification
        await _notificationService.sendStudentApprovalNotification(studentId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'خطأ في الموافقة على الطالب: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Reject student
  Future<bool> rejectStudent(int studentId, String reason) async {
    try {
      final success = await _notificationService.rejectStudent(studentId, reason);
      if (success) {
        // Remove from pending list
        _pendingStudents.removeWhere((student) => student.id == studentId);
        _pendingStudentsCount = _pendingStudents.length;
        notifyListeners();
        
        // Send real-time notification
        await _notificationService.sendStudentRejectionNotification(studentId, reason);
      }
      return success;
    } catch (e) {
      _errorMessage = 'خطأ في رفض الطالب: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Approve project
  Future<bool> approveProject(int projectId) async {
    try {
      final success = await _notificationService.approveProject(projectId);
      if (success) {
        // Remove from pending list
        _pendingProjects.removeWhere((project) => project.id == projectId);
        _pendingProjectsCount = _pendingProjects.length;
        notifyListeners();
        
        // Send real-time notification
        await _notificationService.sendProjectApprovalNotification(projectId);
      }
      return success;
    } catch (e) {
      _errorMessage = 'خطأ في الموافقة على المشروع: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Reject project
  Future<bool> rejectProject(int projectId, String reason) async {
    try {
      final success = await _notificationService.rejectProject(projectId, reason);
      if (success) {
        // Remove from pending list
        _pendingProjects.removeWhere((project) => project.id == projectId);
        _pendingProjectsCount = _pendingProjects.length;
        notifyListeners();
        
        // Send real-time notification
        await _notificationService.sendProjectRejectionNotification(projectId, reason);
      }
      return success;
    } catch (e) {
      _errorMessage = 'خطأ في رفض المشروع: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Start real-time updates
  void _startRealTimeUpdates() {
    // Set up periodic refresh every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (_isLoading) return; // Don't refresh if already loading
      loadPendingStudents();
      loadPendingProjects();
      _startRealTimeUpdates(); // Schedule next update
    });
  }
  
  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
  
  // Refresh all data
  Future<void> refresh() async {
    await loadPendingStudents();
    await loadPendingProjects();
  }
  
  // Dispose
  @override
  void dispose() {
    super.dispose();
  }
} 