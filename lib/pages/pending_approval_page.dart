import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_services.dart';
import 'dart:async';

class PendingApprovalPage extends StatefulWidget {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String serialNumber;

  const PendingApprovalPage({
    super.key,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.serialNumber,
  });

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _statusCheckTimer;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    // بدء فحص حالة الطالب في الوقت الفعلي
    _startStatusChecking();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusChecking() {
    // فحص كل 5 ثوان
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkStudentStatus();
    });
  }

  Future<void> _checkStudentStatus() async {
    if (_isCheckingStatus) return;
    
    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final status = await NotificationService.checkStudentStatus(widget.username);
      
      if (status['exists'] && status['approved']) {
        // الطالب تمت الموافقة عليه
        _statusCheckTimer?.cancel();
        
        // إظهار رسالة نجاح
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('تمت الموافقة!'),
                  ],
                ),
                content: const Text(
                  'تمت الموافقة على طلبك بنجاح! يمكنك الآن تسجيل الدخول واستخدام النظام.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // العودة لصفحة تسجيل الدخول
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error checking student status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xff00577B),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        ' مرحباً بك في نظام ادارة مشاريع التخرج',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // Status Icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.pending_actions,
                              size: 60,
                              color: Colors.orange,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Real-time Status Check Indicator
                          if (_isCheckingStatus)
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'جاري فحص حالة الطلب...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Status Title
                          const Text(
                            'طلبك قيد المراجعة',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff00577B),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Status Description
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  'تم استلام طلب تسجيلك بنجاح',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'سيتم مراجعة طلبك من قبل الإدارة في أقرب وقت ممكن',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // User Information
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'معلومات الطلب:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff00577B),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow('الاسم:', '${widget.firstName} ${widget.lastName}'),
                                _buildInfoRow('اسم المستخدم:', widget.username),
                                _buildInfoRow('البريد الإلكتروني:', widget.email),
                                if (widget.serialNumber.isNotEmpty)
                                  _buildInfoRow('رقم القيد:', widget.serialNumber),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Instructions
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xff00577B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xff00577B).withOpacity(0.3),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xff00577B),
                                  size: 24,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'ماذا يحدث بعد ذلك؟',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff00577B),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '• ستتم مراجعة طلبك من قبل الإدارة\n'
                                  '• سيتم إعلامك عند الموافقة على حسابك\n'
                                  '• يمكنك محاولة تسجيل الدخول لاحقاً للتحقق من حالة طلبك',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: const BorderSide(color: Color(0xff00577B)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'العودة لتسجيل الدخول',
                                    style: TextStyle(
                                      color: Color(0xff00577B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Clear stored data and go to login
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.clear();
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff00577B),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'تسجيل خروج',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Contact Info
                          const Text(
                            'للمساعدة، يرجى التواصل مع الإدارة',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
