// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/widgets/widget_dialog.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'pending_approval_page.dart';

import '../services/login_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool isLoggedIn = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
    _slideController.forward();
    refreshLogin();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> refreshLogin() async {
    // try {
    //   await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: "anotherapp@gmail.com",
    //     password: "anotherapppassword",
    //   );
    // } on FirebaseAuthException catch (e) {
    //   print('Failed with error code: ${e.code}');
    //   print(e.message);
    // }

    await Future.delayed(const Duration(seconds: 1));

    // Assuming the RefreshLoginService returns a boolean indicating the login status
    // final loginStatus = await Provider.of<UserProvider>(context,listen: false).;
    final loginStatus = await refreshLoginService();

    setState(() {
      isLoggedIn = loginStatus;
    });

    // Navigate to the home route if the user is logged in
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xfff5f6fa),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE3F2FD),
                Color(0xFFF5F5F5),
                Color(0xFFE8F5E8),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header Section
                SizedBox(
                  height: media.height * 0.28,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Background Image
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: Image.asset(
                            "assets/app-login-upper-background.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xff00577B).withOpacity(0.8),
                                const Color(0xff00577B).withOpacity(0.6),
                                const Color(0xff00577B).withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Logo & Title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.school,
                                  size: 50,
                                  color: Color(0xff00577B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Gradify",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "نظام إدارة مشاريع التخرج",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Login Form Section
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SingleChildScrollView(
                          child: Consumer<UserProvider>(
                            builder: (context, provider, child) {
                              return Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 30),
                                    // Welcome Text
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "مرحباً بك",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff00577B),
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "سجل دخولك للوصول إلى نظام إدارة مشاريع التخرج",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    // Username Field
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(6),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff00577B).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.person_outline,
                                              color: Color(0xff00577B),
                                              size: 20,
                                            ),
                                          ),
                                          hintText: "اسم المستخدم أو رقم القيد",
                                          hintStyle: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.transparent,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                        ),
                                        validator: provider.emailValidator,
                                        onChanged: (value) {
                                          provider.emailController.text = value.trim();
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Password Field
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.centerLeft,
                                        children: [
                                          TextFormField(
                                            obscureText: !provider.isVisible,
                                            decoration: InputDecoration(
                                              prefixIcon: Container(
                                                margin: const EdgeInsets.all(6),
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xff00577B).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.lock_outline,
                                                  color: Color(0xff00577B),
                                                  size: 20,
                                                ),
                                              ),
                                              hintText: "كلمة المرور",
                                              hintStyle: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                            ),
                                            validator: provider.passwordValidator,
                                            onChanged: (value) {
                                              provider.passwordController.text = value.trim();
                                            },
                                          ),
                                          Positioned(
                                            left: 12,
                                            child: IconButton(
                                              onPressed: () {
                                                provider.isVisible = !provider.isVisible;
                                                setState(() {});
                                              },
                                              icon: Icon(
                                                provider.isVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: const Color(0xff00577B),
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    // Login Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: provider.isLoginLoading ? null : () async {
                                          provider.setLoginLoading(true);
                                          setState(() {});
                                          try {
                                            await provider.loginUser(_formKey);
                                            
                                            if (provider.loggedIn && !provider.loginError) {
                                              Navigator.pushNamed(context, "/home");
                                            } else if (provider.isPendingApproval) {
                                              final studentData = provider.pendingStudentData;
                                              if (studentData != null) {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PendingApprovalPage(
                                                      username: provider.emailController.text,
                                                      email: studentData['email'] ?? '',
                                                      firstName: studentData['first_name'] ?? '',
                                                      lastName: studentData['last_name'] ?? '',
                                                      serialNumber: studentData['serial_number'] ?? '',
                                                    ),
                                                  ),
                                                  (route) => false,
                                                );
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return PendingApprovalDialog(
                                                      username: provider.emailController.text,
                                                    );
                                                  },
                                                );
                                              }
                                            } else if (provider.loginError) {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return LoginErrorDialog(
                                                    errorMessage: provider.errorMessage.isNotEmpty 
                                                        ? provider.errorMessage 
                                                        : "اسم المستخدم أو كلمة المرور خاطئة",
                                                  );
                                                },
                                              );
                                            }
                                          } catch (error) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return LoginErrorDialog(
                                                  errorMessage: error.toString(),
                                                );
                                              },
                                            );
                                          } finally {
                                            provider.setLoginLoading(false);
                                            setState(() {});
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xff00577B),
                                          foregroundColor: Colors.white,
                                          elevation: 8,
                                          shadowColor: const Color(0xff00577B).withOpacity(0.3),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        child: provider.isLoginLoading
                                            ? const SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                "تسجيل الدخول",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    //
                                    // Register Link
                                   Center(child:  Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: const Color(0xff00577B).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'ليس لديك حساب؟',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushNamed(context, '/student-register');
                                            },
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                            ),
                                            child: const Text(
                                              'تسجيل حساب طالب جديد',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xff00577B),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                   ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Footer Section
          // ...existing code...
// Footer Section
Container(
  width: double.infinity,
  height: 70,
  decoration: const BoxDecoration(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, -2),
      ),
    ],
  ),
  child: Stack(
    children: [
      ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Image.asset(
          "assets/app-login-lower-background.png",
          fit: BoxFit.cover,
          width: double.infinity,
          height: 70,
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
// ...existing code...
              
            ),
          ),
        
      
    );
  }
}
