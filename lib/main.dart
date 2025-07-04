import 'package:flutter/material.dart';
import 'package:gradpro/pages/admin_examiner_page.dart';
import 'package:gradpro/pages/admin_page.dart';
import 'package:gradpro/pages/admin_project_page.dart';
import 'package:gradpro/pages/admin_students_page.dart';
import 'package:gradpro/pages/admin_teacher_page.dart';
import 'package:gradpro/pages/chat_page.dart';
import 'package:gradpro/pages/login_page.dart';
import 'package:gradpro/pages/notifications_page.dart';
import 'package:gradpro/pages/pending_approval_page.dart';
import 'package:gradpro/pages/settings_page.dart';
import 'package:gradpro/pages/student_page.dart';
import 'package:gradpro/pages/student_registration_page.dart';
import 'package:gradpro/pages/teacher_page.dart';
import 'package:gradpro/pages/widgets/page_pdf_viewer.dart';
import 'package:gradpro/providers/admin_project_provider.dart';
import 'package:gradpro/providers/admin_student_provider.dart';
import 'package:gradpro/providers/admin_teacher_provider.dart';
import 'package:gradpro/providers/chat_provider.dart';
import 'package:gradpro/providers/edit_project_provider.dart';
import 'package:gradpro/providers/edit_student_provider.dart';
import 'package:gradpro/providers/edit_teacher_provider.dart';
import 'package:gradpro/providers/pdf_provider.dart';
import 'package:gradpro/providers/pdf_viewer_provider.dart';
import 'package:gradpro/providers/register_provider.dart';
import 'package:gradpro/providers/teacher_provider.dart';
import 'package:gradpro/providers/user_provider.dart';
import 'package:gradpro/providers/student_provider.dart';
import 'package:gradpro/services/firebase_notification_service.dart';
import 'package:provider/provider.dart';
import 'package:gradpro/pages/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/logging_state.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    NotificationService.instance.initialize(navigatorKey);
  } catch (e) {
    // If Firebase fails to initialize, continue without it
    print('Firebase initialization failed: $e');
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => StudentProvider()),
    ChangeNotifierProvider(create: (context) => UserProvider()),
    ChangeNotifierProvider(create: (context) => TeacherProvider()),
    ChangeNotifierProvider(create: (context) => AdminStudentProvider()),
    ChangeNotifierProvider(create: (context) => RegisterProvider()),
    ChangeNotifierProvider(create: (context) => AdminEditStudentProvider()),
    ChangeNotifierProvider(create: (context) => AdminTeacherProvider()),
    ChangeNotifierProvider(create: (context) => AdminEditTeacherProvider()),
    ChangeNotifierProvider(create: (context) => AdminProjectProvider()),
    ChangeNotifierProvider(create: (context) => AdminEditProjectProvider()),
    ChangeNotifierProvider(create: (context) => ChatProvider()),
    ChangeNotifierProvider(create: (context) => PdfProvider()),
    ChangeNotifierProvider(create: (context) => PdfViewerProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ManagerApp',
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/student-register': (context) => const StudentRegistrationPage(),
        '/pending-approval': (context) => const PendingApprovalPage(
              username: '',
              email: '',
              firstName: '',
              lastName: '',
              serialNumber: '',
            ),
        '/notifications': (context) => const NotificationsPage(),
        '/student': (context) => const StudentPage(),
        '/settings': (context) => const SettingsPage(),
        '/chat': (context) => const ChatPage(),
        '/teacher': (context) => const TeacherPage(),
        '/pdfViewer': (context) => const PdfView(),
        '/admin': (context) => const AdminPage(),
        '/adminStudentList': (context) => const AdminStudentsPage(),
        '/adminStudentAdd': (context) => const AdminStudentAddPage(),
        '/adminStudentEdit': (context) => const AdminStudentEditPage(),
        '/adminStudentDelete': (context) => const AdminStudentDeletePage(),
        '/adminTeacherList': (context) => const AdminTeacherListPage(),
        '/adminTeacherAdd': (context) => const AdminTeacherAddPage(),
        '/adminTeacherEdit': (context) => const AdminTeacherEditPage(),
        '/adminTeacherDelete': (context) => const AdminTeacherDeletePage(),
        '/adminExaminerList': (context) => const AdminExaminerListPage(),
        '/adminExaminerAdd': (context) => const AdminExaminerAddPage(),
        '/adminExaminerEdit': (context) => const AdminExaminerEditPage(),
        '/adminExaminerDelete': (context) => const AdminExaminerDeletePage(),
        '/adminProjectList': (context) => const AdminProjectListPage(),
        '/adminProjectDelete': (context) => const AdminProjectDeletePage(),
        '/adminProjectAccept': (context) => const AdminProjectAcceptPage(),
        '/adminProjectAddStudent': (context) =>
            const AdminProjectAddStudentPage(),
        '/adminProjectSetTeacher': (context) =>
            const AdminProjectSetTeacherPage(),
        '/adminProjectEdit': (context) => const AdminProjectEditPage(),
      },
      theme: ThemeData(
        fontFamily: "Tajawal",
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff00577B)),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, login, child) {
        return FutureBuilder<Logging>(
          future: login.refreshLogin,
          builder: (BuildContext context, AsyncSnapshot<Logging> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Still loading
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("جاري التحميل..."),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              // Error occurred - show login page instead of error
              return const LoginPage();
            } else if (snapshot.hasData) {
              // Check the login state
              switch (snapshot.data) {
                case Logging.student:
                  return const StudentPage();
                case Logging.admin:
                  return const AdminPage();
                case Logging.teacher:
                  return const TeacherPage();
                case Logging.notUser:
                  return const LoginPage();
                case Logging.notType:
                  return const LoginPage();
                default:
                  return const LoginPage();
              }
            } else {
              // Fallback: show login
              return const LoginPage();
            }
          },
        );
      },
    );
  }
}
