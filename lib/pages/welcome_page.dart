import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gradpro/providers/user_provider.dart';
import 'package:gradpro/services/token_manager.dart';
import 'package:gradpro/services/internet_services.dart';
import 'package:gradpro/models/logging_state.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isCheckingToken = false;
  bool _hasCheckedToken = false;

  @override
  void initState() {
    super.initState();
    // تحقق من التوكن عند بدء الصفحة
    _checkTokenOnStart();
  }

  Future<void> _checkTokenOnStart() async {
    if (_hasCheckedToken) return;
    
    setState(() {
      _isCheckingToken = true;
    });

    try {

      
      // تحميل التوكن بسرعة
      await InternetService().loadTokenFromPrefs();
      
      // انتظار قصير جداً
      await Future.delayed(const Duration(milliseconds: 100));
      
      // تحقق من وجود توكن صالح
      if (InternetService().isAuthorized()) {

        
        // تحقق سريع من حالة المستخدم
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final loginState = await userProvider.refreshLogin;
        
        if (loginState != Logging.notUser && loginState != Logging.notType) {

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
            return;
          }
        }
      }
      
      
    } catch (e) {
      
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingToken = false;
          _hasCheckedToken = true;
        });
      }
    }
  }

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
                if (_isCheckingToken)
                  const Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00577B)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "جاري التحقق من تسجيل الدخول...",
                        style: TextStyle(
                          color: Color(0xff00577B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                else
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
