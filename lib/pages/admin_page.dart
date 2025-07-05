import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gradpro/providers/user_provider.dart';
import 'package:gradpro/providers/notification_provider.dart';
import 'package:gradpro/pages/pending_approval_page.dart';
import 'package:gradpro/pages/real_time_notifications_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // تحقق من أن المستخدم له صلاحية أدمن
        if (userProvider.group != 1) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    "لا تملك صلاحية الوصول لهذه الصفحة",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text("العودة لصفحة تسجيل الدخول"),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'لوحة التحكم',
              style: TextStyle(
                color: Color(0xFFF9F9F9),
              ),
            ),
            centerTitle: true,
            backgroundColor: Color(0xff00577B),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Colors.white),
                        tooltip: "الإشعارات في الوقت الفعلي",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RealTimeNotificationsPage(),
                            ),
                          );
                        },
                      ),
                      if (notificationProvider.totalPendingCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${notificationProvider.totalPendingCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: "الإعدادات",
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildNotificationsSection(context),
                  _buildSection(
                    context,
                    title: "الطلبة",
                    image: "assets/students-image-admin.png",
                    buttons: [
                      _buildButton(context, "قائمة الطلبة", "/adminStudentList"),
                      _buildButton(context, "إضافة طالب", "/adminStudentAdd"),
                      _buildButton(context, "تعديل بيانات", "/adminStudentEdit"),
                      _buildButton(context, "حذف طالب", "/adminStudentDelete"),
                    ],
                  ),
                  _buildSection(
                    context,
                    title: "الاساتذة",
                    image: "assets/teachers-image-admin.png",
                    buttons: [
                      _buildButton(context, "قائمة الاساتذة", "/adminTeacherList"),
                      _buildButton(context, "إضافة استاذ", "/adminTeacherAdd"),
                      _buildButton(context, "تعديل بيانات استاذ", "/adminTeacherEdit"),
                      _buildButton(context, "حذف استاذ", "/adminTeacherDelete"),
                    ],
                  ),
                  _buildSection(
                    context,
                    title: "الممتحنين",
                    image: "assets/examiner-image-admin.png",
                    buttons: [
                      _buildButton(context, "قائمة الممتحنين", "/adminExaminerList"),
                      _buildButton(context, "إضافة ممتحن", "/adminExaminerAdd"),
                      _buildButton(context, "تعديل بيانات ممتحن", "/adminExaminerEdit"),
                      _buildButton(context, "حذف ممتحن", "/adminExaminerDelete"),
                    ],
                  ),
                  _buildSection(
                    context,
                    title: "المشاريع",
                    image: "assets/project-image-admin.png",
                    buttons: [
                      _buildButton(context, "الموافقة علي مقترح", "/adminProjectAccept"),
                      _buildButton(context, "إضافة طالب الي مشروع", "/adminProjectAddStudent"),
                      _buildButton(context, "تحديد مشرف لمشروع", "/adminProjectSetTeacher"),
                      _buildButton(context, "أرشيف المشاريع", "/adminProjectList"),
                      _buildButton(context, "تعديل بيانات مشروع", "/adminProjectEdit"),
                      _buildButton(context, "حذف مشروع", "/adminProjectDelete"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff00577B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "الإشعارات في الوقت الفعلي",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const Spacer(),
                    if (notificationProvider.totalPendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${notificationProvider.totalPendingCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildNotificationCard(
                        context,
                        "طلبات الطلاب",
                        notificationProvider.pendingStudentsCount,
                        Icons.person,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNotificationCard(
                        context,
                        "طلبات المشاريع",
                        notificationProvider.pendingProjectsCount,
                        Icons.assignment,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RealTimeNotificationsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('عرض جميع الطلبات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff00577B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String image,
    required List<Widget> buttons,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(image, height: 40),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              textDirection: TextDirection.rtl,
              alignment: WrapAlignment.spaceAround,
              children: buttons,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, String routeName) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, routeName),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: const Color(0xff00577B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(title),
    );
  }
}

class AdminElevatedButton extends StatelessWidget {
  final void Function()? onPress;
  final String title;

  const AdminElevatedButton({super.key, this.onPress, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 50,
        width: 300,
        child: ElevatedButton(
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.white),
                elevation: MaterialStatePropertyAll(4),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))))),
            onPressed: onPress,
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black),
            )),
      ),
    );
  }
}

class AdminPageHeadTitle extends StatelessWidget {
  final String title;
  final String image;

  const AdminPageHeadTitle(
      {super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9),
          boxShadow: [
            BoxShadow(
              color: Color(0x000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Image.asset(
                  // 'assets/students-image-admin.png',
                  image),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
