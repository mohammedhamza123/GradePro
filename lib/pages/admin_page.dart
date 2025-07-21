import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildButton(
                      context, "تعديل بيانات استاذ", "/adminTeacherEdit"),
                  _buildButton(context, "حذف استاذ", "/adminTeacherDelete"),
                ],
              ),
              _buildSection(
                context,
                title: "المشاريع",
                image: "assets/project-image-admin.png",
                buttons: [
                  _buildButton(
                      context, "الموافقة علي مقترح", "/adminProjectAccept"),
                  _buildButton(context, "إضافة طالب الي مشروع",
                      "/adminProjectAddStudent"),
                  _buildButton(
                      context, "تحديد مشرف لمشروع", "/adminProjectSetTeacher"),
                  _buildButton(context, "أرشيف المشاريع", "/adminProjectList"),
                  _buildButton(
                      context, "تعديل بيانات مشروع", "/adminProjectEdit"),
                  _buildButton(context, "حذف مشروع", "/adminProjectDelete"),
                ],
              ),
            ],
          ),
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
