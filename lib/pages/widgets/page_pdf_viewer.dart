import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradpro/providers/pdf_viewer_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfView extends StatefulWidget {
  const PdfView({super.key});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عرض PDF التقييم'),
        backgroundColor: const Color(0xff00577B),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<PdfViewerProvider>(builder: (context, provider, _c) {
        if (provider.pdf.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'لا يوجد رابط PDF محدد',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
          );
        }

        // التحقق من نوع الرابط
        final isDirectLink = provider.pdf.contains('.pdf') || 
                           provider.pdf.contains('direct') ||
                           provider.pdf.contains('cdn');
        final isGoFilePage = provider.pdf.contains('gofile.io/d/');

        // إذا كان رابط مباشر، اعرض PDF مباشرة
        if (isDirectLink) {
          return SfPdfViewer.network(
            provider.pdf,
            canShowPaginationDialog: false,
            canShowScrollHead: false,
            canShowScrollStatus: false,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              print('PDF loaded successfully from direct link');
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              print('PDF load failed: ${details.error}');
              setState(() {
                _errorMessage = 'فشل في تحميل PDF: ${details.error}';
              });
            },
          );
        }

        // إذا كان رابط صفحة GoFile، اعرض الخيارات
        if (isGoFilePage) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // أيقونة PDF
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xff00577B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    size: 60,
                    color: Color(0xff00577B),
                  ),
                ),
                const SizedBox(height: 32),
                
                // عنوان
                const Text(
                  'ملف PDF التقييم جاهز',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff00577B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // رسالة توضيحية
                const Text(
                  'تم حفظ ملف PDF التقييم بنجاح على GoFile',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // معلومات الرابط
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'رابط الملف:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        provider.pdf,
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // رسالة مهمة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'هذا رابط صفحة GoFile',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'اضغط على "فتح في المتصفح" لتحميل PDF',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // الأزرار
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final Uri url = Uri.parse(provider.pdf);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('لا يمكن فتح الرابط'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('خطأ في فتح الرابط: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff00577B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_browser, size: 24),
                    label: const Text(
                      'فتح PDF في المتصفح',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: provider.pdf));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ الرابط إلى الحافظة'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff00577B),
                      side: const BorderSide(color: Color(0xff00577B)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.copy, size: 24),
                    label: const Text(
                      'نسخ الرابط',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // زر رجوع
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'رجوع',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }

        // إذا كان هناك خطأ
        if (_errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        // عرض افتراضي
        return const Center(
          child: Text('جاري تحميل PDF...'),
        );
      }),
    );
  }
}
