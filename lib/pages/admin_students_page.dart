import 'package:flutter/material.dart';
import 'package:gradpro/models/widget_FormTextField.dart';
import 'package:gradpro/pages/widgets/widget_admin_base_page.dart';
import 'package:gradpro/pages/widgets/widget_confirm_delete.dart';
import 'package:gradpro/pages/widgets/widget_searchbar.dart';
import 'package:gradpro/pages/widgets/student_list_item.dart';
import 'package:gradpro/providers/edit_student_provider.dart';
import 'package:gradpro/providers/register_provider.dart';
import 'package:provider/provider.dart';
import '../providers/admin_student_provider.dart';
import 'package:gradpro/models/student_details_list.dart';
import 'package:gradpro/pages/widgets/page_details.dart';
import 'package:gradpro/pages/widgets/notification_badge.dart';

class AdminStudentsPage extends StatefulWidget {
  const AdminStudentsPage({Key? key}) : super(key: key);

  @override
  State<AdminStudentsPage> createState() => _AdminStudentsPageState();
}

class _AdminStudentsPageState extends State<AdminStudentsPage> {
  @override
  void initState() {
    super.initState();
    // تحميل الطلبة عند فتح الصفحة - مرة واحدة فقط
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // تأكد من أن الصفحة لا تزال موجودة قبل التحميل
      if (mounted) {
        context.read<AdminStudentProvider>().refreshStudents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة الطلبة',
          style: TextStyle(
            color: Color(0xFFF9F9F9),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff00577B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "تحديث",
            onPressed: () {
              context.read<AdminStudentProvider>().refreshStudents();
            },
          ),
          NotificationBadge(child: SizedBox.shrink()),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xfff5f6fa),
              Colors.white,
            ],
          ),
        ),
        child: Consumer<AdminStudentProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: () async {
                await provider.refreshStudents();
              },
              child: _buildContent(provider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(AdminStudentProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00577B)),
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل البيانات...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff00577B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تحميل البيانات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdminStudentProvider>().refreshStudents();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00577B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final students = provider.studentList;
    
    if (students.isEmpty) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff00577B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_outline,
                    size: 48,
                    color: const Color(0xff00577B),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد طلبة مسجلين',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff00577B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اسحب للأسفل للتحديث',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // شريط البحث المحسن
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: provider.searchbarController,
            decoration: InputDecoration(
              hintText: 'البحث عن طالب...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(
                Icons.search,
                color: const Color(0xff00577B),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onChanged: (value) {
              provider.filterStudentList();
            },
          ),
        ),
        
        // إحصائيات محسنة
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  count: provider.approvedStudents.length,
                  label: 'معتمد',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  count: provider.pendingStudents.length,
                  label: 'في الانتظار',
                  color: Colors.orange,
                  icon: Icons.pending,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // قائمة الطلبة
        Expanded(
          child: provider.filterList.isNotEmpty
              ? _buildStudentList(provider.filterList, provider)
              : _buildStudentList(students, provider),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required int count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<StudentDetail> students, AdminStudentProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return InkWell(
          onTap: () => _showStudentDetails(student),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // صورة الطالب
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: const AssetImage("assets/default_profile.jpg"),
                    backgroundColor: const Color(0xff00577B).withOpacity(0.1),
                  ),
                  const SizedBox(width: 16),
                  // معلومات الطالب
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${student.user.firstName} ${student.user.lastName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'اسم المستخدم: ${student.user.username}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'رقم القيد: ${student.serialNumber ?? 'غير محدد'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // حالة الطالب
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: student.isApproved == true 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: student.isApproved == true 
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          student.isApproved == true ? Icons.check_circle : Icons.pending,
                          size: 16,
                          color: student.isApproved == true ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          student.isApproved == true ? 'معتمد' : 'في انتظار',
                          style: TextStyle(
                            fontSize: 12,
                            color: student.isApproved == true ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStudentDetails(StudentDetail student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff00577B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xff00577B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تفاصيل الطالب',
                style: const TextStyle(
                  color: Color(0xff00577B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('الاسم', '${student.user.firstName} ${student.user.lastName}'),
            _buildDetailRow('اسم المستخدم', student.user.username),
            _buildDetailRow('البريد الإلكتروني', student.user.email ?? 'غير محدد'),
            _buildDetailRow('رقم الهاتف', student.phoneNumber?.toString() ?? 'غير محدد'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: student.isApproved == true 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: student.isApproved == true 
                      ? Colors.green.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    student.isApproved == true ? Icons.check_circle : Icons.pending,
                    size: 16,
                    color: student.isApproved == true ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    student.isApproved == true ? 'معتمد' : 'في انتظار الموافقة',
                    style: TextStyle(
                      color: student.isApproved == true ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff00577B),
            ),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff00577B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(StudentDetail student, AdminStudentProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'موافقة على الطالب',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من الموافقة على الطالب ${student.user.firstName} ${student.user.lastName}؟',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await provider.approveStudent(student.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تمت الموافقة على الطالب بنجاح'),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في الموافقة على الطالب: $e'),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('موافقة'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(StudentDetail student, int index, AdminStudentProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'حذف الطالب',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف الطالب ${student.user.firstName} ${student.user.lastName}؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await provider.deleteStudent(student.user.id, index, false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم حذف الطالب بنجاح'),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في حذف الطالب: $e'),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(StudentDetail student, AdminStudentProvider provider) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'رفض الطالب',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'هل أنت متأكد من رفض الطالب ${student.user.firstName} ${student.user.lastName}؟',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'سبب الرفض (اختياري)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xff00577B)),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await provider.rejectStudent(
                  student.id,
                  reason: reasonController.text.isNotEmpty ? reasonController.text : 'لم يتم تحديد سبب',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم رفض الطالب بنجاح'),
                    backgroundColor: Colors.orange.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في رفض الطالب: $e'),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }
}

class AdminStudentAddPage extends StatelessWidget {
  const AdminStudentAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      child: Expanded(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "طلبات تسجيل الطلاب",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            // قسم الطلاب الذين ينتظرون الموافقة
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pending, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          "الطلاب الذين ينتظرون الموافقة",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Consumer<AdminStudentProvider>(
                        builder: (context, provider, child) {
                          return FutureBuilder(
                            future: provider.loadStudents(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final students = snapshot.data!;
                                final pendingStudents = students.where((student) => 
                                    student.isApproved == false).toList();
                                
                                if (pendingStudents.isNotEmpty) {
                                  return ListView.builder(
                                    itemCount: pendingStudents.length,
                                    itemBuilder: (context, index) {
                                      final item = pendingStudents[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        child: ListTile(
                                          leading: const CircleAvatar(
                                            backgroundColor: Colors.orange,
                                            child: Icon(Icons.pending, color: Colors.white),
                                          ),
                                          title: Text(
                                            '${item.user.firstName} ${item.user.lastName}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('اسم المستخدم: ${item.user.username}'),
                                              Text('رقم القيد: ${item.serialNumber ?? 'غير محدد'}'),
                                              Text('البريد الإلكتروني: ${item.user.email ?? 'غير محدد'}'),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  try {
                                                    await provider.approveStudent(item.id);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('تمت الموافقة على الطالب بنجاح'),
                                                        backgroundColor: Colors.green,
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('خطأ: ${e.toString()}'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: const Icon(Icons.check, color: Colors.green),
                                                tooltip: 'موافقة',
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  // تأكيد قبل الحذف
                                                  bool? confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text('تأكيد رفض الطالب'),
                                                        content: Text(
                                                          'هل أنت متأكد من رفض الطالب ${item.user.firstName} ${item.user.lastName}؟\n\nسيتم حذف الطالب نهائياً من النظام ولا يمكن التراجع عن هذا الإجراء.',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.of(context).pop(false),
                                                            child: const Text('إلغاء'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () => Navigator.of(context).pop(true),
                                                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                            child: const Text('رفض وحذف'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                  
                                                  if (confirm == true) {
                                                    try {
                                                      await provider.rejectStudent(item.id);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('تم رفض الطالب وحذفه من النظام'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('خطأ: ${e.toString()}'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                tooltip: 'رفض وحذف',
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 48,
                                          color: Colors.green,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'لا يوجد طلاب في انتظار الموافقة',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                              if (snapshot.connectionState == ConnectionState.done) {
                                if (snapshot.hasError) {
                                  return Text("خطأ في تحميل البيانات: ${snapshot.error}");
                                }
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminStudentDeletePage extends StatelessWidget {
  const AdminStudentDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      child: Consumer<AdminStudentProvider>(
        builder: (context, provider, child) {
          return Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "حذف حساب طالب",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        "بحث",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    ],
                  ),
                ),
                AdminSearchbar(
                  onChanged: (String val) {
                    provider.filterStudentList();
                  },
                  editingController: provider.searchbarController,
                ),
                Expanded(
                  child: FutureBuilder(
                    future: provider.loadStudents(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final students = provider.filterList.isNotEmpty 
                            ? provider.filterList 
                            : snapshot.data!;
                        
                        return ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final item = students[index];
                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                StudentListItem(
                                  imageLink: "",
                                  firstName: item.user.firstName,
                                  lastName: item.user.lastName,
                                  userName: item.user.username,
                                ),
                                Positioned(
                                  left: 16,
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('تأكيد الحذف'),
                                            content: Text(
                                              'هل أنت متأكد من حذف الطالب ${item.user.firstName} ${item.user.lastName}؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text('إلغاء'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  try {
                                                    await provider.deleteStudent(item.user.id, index, false);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('تم حذف الطالب بنجاح'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('خطأ: ${e.toString()}'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                child: const Text('حذف'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Text("خطأ في تحميل البيانات: ${snapshot.error}");
                        }
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdminStudentEditPage extends StatelessWidget {
  const AdminStudentEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      child: Consumer<AdminEditStudentProvider>(
        builder: (context, provider, child) {
          return Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "تعديل بيانات طالب",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        "بحث",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    ],
                  ),
                ),
                provider.student == null
                    ? AdminSearchbar(
                        onChanged: (String val) {
                          provider.filterStudentList();
                        },
                        editingController: provider.searchbarController,
                      )
                    : Container(),
                Expanded(
                  child: provider.student == null
                      ? FutureBuilder(
                          future: provider.loadStudents(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final students = provider.filterList.isNotEmpty
                                  ? provider.filterList
                                  : snapshot.data!;
                              
                              return ListView.builder(
                                itemCount: students.length,
                                itemBuilder: (context, index) {
                                  final item = students[index];
                                  return Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          provider.setStudent(item);
                                        },
                                        child: StudentListItem(
                                          imageLink: "",
                                          firstName: item.user.firstName,
                                          lastName: item.user.lastName,
                                          userName: item.user.username,
                                        ),
                                      ),
                                      Positioned(
                                        left: 16,
                                        child: IconButton(
                                          onPressed: () {
                                            provider.setStudent(item);
                                          },
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasError) {
                                return Text("خطأ في تحميل البيانات: ${snapshot.error}");
                              }
                            }
                            return const Center(child: CircularProgressIndicator());
                          },
                        )
                      : SingleChildScrollView(
                          child: Form(
                            key: provider.formKey,
                            onChanged: provider.onFromStateChanged,
                            child: Column(
                              children: [
                                provider.error.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          provider.error,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    : Container(),
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
                                const SizedBox(height: 20),
                                !provider.isLoading
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                provider.setStudent(null);
                                              },
                                              style: const ButtonStyle(
                                                backgroundColor: MaterialStatePropertyAll(
                                                  Color(0xFF0000FF),
                                                ),
                                              ),
                                              child: const Text(
                                                "رجوع لقائمة الطلبة",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 50,
                                            child: ElevatedButton(
                                              onPressed: provider.canEdit
                                                  ? () async {
                                                      try {
                                                        await provider.updateStudent();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('تم تحديث بيانات الطالب بنجاح'),
                                                            backgroundColor: Colors.green,
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('خطأ في تحديث البيانات: $e'),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  : null,
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                                  (states) {
                                                    if (states.contains(MaterialState.disabled)) {
                                                      return Colors.grey;
                                                    }
                                                    return const Color(0xFF0000FF);
                                                  },
                                                ),
                                              ),
                                              child: const Text(
                                                "حفظ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
