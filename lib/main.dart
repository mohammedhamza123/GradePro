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
import 'package:gradpro/providers/notification_provider.dart';
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
import 'firebase_options.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    NotificationService.instance.initialize(navigatorKey);
  } catch (e) {
    // If Firebase fails to initialize, continue without it
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => AdminStudentProvider()),
        ChangeNotifierProvider(create: (_) => AdminTeacherProvider()),
        ChangeNotifierProvider(create: (_) => AdminProjectProvider()),
        ChangeNotifierProvider(create: (_) => AdminEditStudentProvider()),
        ChangeNotifierProvider(create: (_) => AdminEditTeacherProvider()),
        ChangeNotifierProvider(create: (_) => AdminEditProjectProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PdfProvider()),
        ChangeNotifierProvider(create: (_) => PdfViewerProvider()),
      ],
      child: MaterialApp(
        title: 'Gradify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          scaffoldBackgroundColor: const Color(0xfff5f6fa),
          fontFamily: 'Tajawal',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/student': (context) => const StudentPage(),
          '/teacher': (context) => const TeacherPage(),
          '/admin': (context) => const AdminPage(),
          '/admin-students': (context) => const AdminStudentsPage(),
          '/admin-teachers': (context) => const AdminTeacherListPage(),
          '/admin-projects': (context) => const AdminProjectListPage(),
          '/admin-examiners': (context) => const AdminExaminerListPage(),
          '/student-register': (context) => const StudentRegistrationPage(),
          '/settings': (context) => const SettingsPage(),
          '/notifications': (context) => const NotificationsPage(),
          '/chat': (context) => const ChatPage(),
          '/pdfViewer': (context) => const PdfView(),
          '/pending-approval': (context) => const PendingApprovalPage(
                username: '',
                email: '',
                firstName: '',
                lastName: '',
                serialNumber: '',
              ),
          // Admin Student Routes
          '/adminStudentList': (context) => const AdminStudentsPage(),
          '/adminStudentAdd': (context) => const AdminStudentAddPage(),
          '/adminStudentEdit': (context) => const AdminStudentEditPage(),
          '/adminStudentDelete': (context) => const AdminStudentDeletePage(),
          // Admin Teacher Routes
          '/adminTeacherList': (context) => const AdminTeacherListPage(),
          '/adminTeacherAdd': (context) => const AdminTeacherAddPage(),
          '/adminTeacherEdit': (context) => const AdminTeacherEditPage(),
          '/adminTeacherDelete': (context) => const AdminTeacherDeletePage(),
          // Admin Examiner Routes
          '/adminExaminerList': (context) => const AdminExaminerListPage(),
          '/adminExaminerAdd': (context) => const AdminExaminerAddPage(),
          '/adminExaminerEdit': (context) => const AdminExaminerEditPage(),
          '/adminExaminerDelete': (context) => const AdminExaminerDeletePage(),
          // Admin Project Routes
          '/adminProjectAccept': (context) => const AdminProjectAcceptPage(),
          '/adminProjectAddStudent': (context) => const AdminProjectAddStudentPage(),
          '/adminProjectSetTeacher': (context) => const AdminProjectSetTeacherPage(),
          '/adminProjectList': (context) => const AdminProjectListPage(),
          '/adminProjectEdit': (context) => const AdminProjectEditPage(),
          '/adminProjectDelete': (context) => const AdminProjectDeletePage(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, login, child) {
        // إذا كان المستخدم مسجل دخول بالفعل، انتقل مباشرة
        if (login.loggedIn && login.user != null) {
          switch (login.group) {
            case 1:
              return const AdminPage();
            case 2:
              return const StudentPage();
            case 3:
              return const TeacherPage();
            default:
              return const LoginPage();
          }
        }

        return FutureBuilder<Logging>(
          future: login.refreshLogin,
          builder: (BuildContext context, AsyncSnapshot<Logging> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Still loading - show a faster loading indicator
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "جاري التحقق...",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              // Error occurred - show login page instead of error
              return const LoginPage();
            } else if (snapshot.hasData) {
              // Check the login state and redirect to appropriate page
              switch (snapshot.data) {
                case Logging.student:
                  return const StudentPage(); // Student users (group 2)
                case Logging.admin:
                  return const AdminPage(); // Admin users (group 1)
                case Logging.teacher:
                  return const TeacherPage(); // Teacher users (group 3)
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
