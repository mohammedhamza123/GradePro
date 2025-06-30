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
import 'package:provider/provider.dart';
import 'package:gradpro/pages/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:firebase_core/firebase_core.dart';

// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // طباعة FCM Token مباشرة عند بدء التطبيق
  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Token (from main): ' + (token ?? 'null'));
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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // يمكنك معالجة الإشعار هنا
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
        '/': (context) => const WelcomePage(),
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
      // home:const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    setupFCM();
  }

  void setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    String? token = await messaging.getToken();
    print("FCM Token: $token");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      print('Message data: \\${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: \\${message.notification}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, login, child) {
        return FutureBuilder(
          future: login.refreshLogin,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData || login.user != null) {
              switch (login.group) {
                case 2:
                  return const StudentPage();
                case 1:
                  return const AdminPage();
                case 3:
                  return const TeacherPage();
              }
            } else if (snapshot.hasError) {
              return const Text("error");
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
    );
  }
}
