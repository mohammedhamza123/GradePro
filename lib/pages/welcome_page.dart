import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f6fa),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/bb.png',
                  height: 400,
                ),
                const SizedBox(height: 20),
                const Text(
                  'مرحبًا بكم في نظام إدارة مشاريع التخرج',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff00577B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'هذا النظام يساعد الطلاب والمشرفين والإدارة على تتبع ومتابعة مشاريع التخرج بكل سهولة.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: () {
                    try {
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('خطأ في الاتصال'),
                          content: Text('تعذر الاتصال بالسيرفر. تأكد من الشبكة وحاول مرة أخرى.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('حسناً'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00577B),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 12),
                  ),
                  child: const Text(
                    'بدء الاستخدام',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
