import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/register_provider.dart';
import '../models/widget_FormTextField.dart';
import 'pending_approval_page.dart';

class StudentRegistrationPage extends StatelessWidget {
  const StudentRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل طالب جديد'),
          backgroundColor: const Color(0xff00577B),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<RegisterProvider>(
            builder: (context, provider, child) {
              return Form(
                key: provider.formKey,
                onChanged: provider.onFromStateChanged,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // رسالة ترحيب
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xff00577B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.school,
                            size: 48,
                            color: Color(0xff00577B),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'تسجيل حساب طالب جديد',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff00577B),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'سيتم مراجعة طلبك من قبل الإدارة قبل تفعيل الحساب',
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
                    
                    // رسائل الخطأ والنجاح
                    if (provider.error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          provider.error,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    
                    if (provider.success.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.success,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'سيتم إعلامك عند موافقة الإدارة على حسابك',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to pending approval page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PendingApprovalPage(
                                      username: provider.userName.text,
                                      email: provider.email.text,
                                      firstName: provider.firstName.text,
                                      lastName: provider.lastName.text,
                                      serialNumber: provider.serialNumber.text,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff00577B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'عرض تفاصيل الطلب',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // حقول التسجيل
                    FormTextField(
                      hint: "البريد الالكتروني",
                      icon: Icons.email,
                      isPassword: false,
                      validator: provider.validateEmail,
                      onChanged: (value) {
                        if (provider.validateEmail(value) == null) {
                          provider.email.text = value;
                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Text(
                        'ملاحظة: يجب أن يكون البريد الإلكتروني فريداً وغير مستخدم مسبقاً',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    FormTextField(
                      hint: "اسم المستخدم",
                      icon: Icons.person,
                      isPassword: false,
                      validator: provider.validateUserName,
                      onChanged: (value) {
                        if (provider.validateUserName(value) == null) {
                          provider.userName.text = value;
                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Text(
                        'ملاحظة: يجب أن يكون اسم المستخدم فريداً وغير مستخدم مسبقاً',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    FormTextField(
                      hint: "رقم القيد",
                      icon: Icons.numbers,
                      isPassword: false,
                      validator: provider.validateSerial,
                      onChanged: (value) {
                        if (provider.validateSerial(value) == null) {
                          provider.serialNumber.text = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    FormTextField(
                      hint: "الإسم الاول",
                      icon: Icons.person,
                      isPassword: false,
                      validator: provider.validateName,
                      onChanged: (value) {
                        if (provider.validateName(value) == null) {
                          provider.firstName.text = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    FormTextField(
                      hint: "الإسم الأخير",
                      icon: Icons.person,
                      isPassword: false,
                      validator: provider.validateName,
                      onChanged: (value) {
                        if (provider.validateName(value) == null) {
                          provider.lastName.text = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    FormTextField(
                      hint: "كلمة المرور",
                      icon: Icons.password,
                      isPassword: true,
                      validator: provider.validatePassword,
                      onChanged: (value) {
                        if (provider.validatePassword(value) == null) {
                          provider.password.text = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    FormTextField(
                      hint: "تأكيد كلمة المرور",
                      icon: Icons.password,
                      isPassword: true,
                      validator: provider.validateConfirmPassword,
                      onChanged: (value) {
                        if (provider.validateConfirmPassword(value) == null) {
                          provider.confirmPassword.text = value;
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // زر التسجيل
                    if (!provider.isLoading)
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: provider.canRegister
                              ? () {
                                  provider.register(false, null);
                                }
                              : null,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey;
                                }
                                return const Color(0xff00577B);
                              },
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          child: const Text(
                            "تسجيل الحساب",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'جاري التسجيل...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // رابط العودة لتسجيل الدخول
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'لديك حساب بالفعل؟ ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff00577B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 
