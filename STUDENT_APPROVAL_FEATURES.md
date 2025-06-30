# ميزات نظام الموافقة على الطلاب

## نظرة عامة
تم إضافة نظام شامل لإدارة طلبات تسجيل الطلاب الجدد مع إشعارات وتتبع حالة الطلب.

## الميزات الجديدة

### 1. صفحة حالة الانتظار (Pending Approval Page)
- **الموقع**: `lib/pages/pending_approval_page.dart`
- **الوظيفة**: عرض حالة طلب تسجيل الطالب بعد التسجيل الناجح
- **المميزات**:
  - تصميم جذاب مع رسوم متحركة
  - عرض معلومات الطلب (الاسم، اسم المستخدم، البريد الإلكتروني، رقم القيد)
  - تعليمات واضحة حول الخطوات التالية
  - أزرار للعودة لتسجيل الدخول أو تسجيل الخروج

### 2. نظام الإشعارات (Notification System)
- **الموقع**: `lib/services/notification_services.dart`
- **الوظيفة**: إدارة الإشعارات المحلية للطلاب
- **المميزات**:
  - حفظ الإشعارات محلياً
  - تتبع حالة القراءة
  - إشعارات للموافقة والرفض
  - إدارة الإشعارات (حذف، تحديد كمقروء)

### 3. صفحة الإشعارات (Notifications Page)
- **الموقع**: `lib/pages/notifications_page.dart`
- **الوظيفة**: عرض جميع الإشعارات للطالب
- **المميزات**:
  - قائمة الإشعارات مع التصميم
  - تمييز الإشعارات غير المقروءة
  - خيارات لإدارة الإشعارات
  - عرض الوقت النسبي للإشعارات

### 4. تحسينات تسجيل الدخول
- **الموقع**: `lib/pages/login_page.dart` و `lib/providers/user_provider.dart`
- **الوظيفة**: تحسين رسائل الخطأ وإضافة dialog خاص بحالة الانتظار
- **المميزات**:
  - dialog مخصص للطلاب في حالة الانتظار
  - رسائل خطأ محسنة
  - تمييز بين الطلاب والمستخدمين العاديين

### 5. تحسينات صفحة الإدمن
- **الموقع**: `lib/pages/admin_students_page.dart` و `lib/providers/admin_student_provider.dart`
- **الوظيفة**: إرسال إشعارات عند الموافقة أو الرفض
- **المميزات**:
  - إرسال إشعارات تلقائية عند الموافقة
  - إرسال إشعارات عند الرفض مع السبب
  - تحديث واجهة المستخدم تلقائياً

### 6. Widget الإشعارات (Notification Badge)
- **الموقع**: `lib/pages/widgets/notification_badge.dart`
- **الوظيفة**: عرض عدد الإشعارات غير المقروءة
- **المميزات**:
  - عرض العدد على أي widget
  - تحديث تلقائي للعدد
  - تصميم قابل للتخصيص

## التدفق الجديد

### للطالب الجديد:
1. **التسجيل**: الطالب يسجل حساب جديد
2. **صفحة الانتظار**: يتم توجيهه لصفحة حالة الانتظار
3. **محاولة الدخول**: عند محاولة تسجيل الدخول يظهر dialog خاص
4. **الإشعار**: عند الموافقة يتلقى إشعار
5. **الدخول**: يمكنه تسجيل الدخول بعد الموافقة

### للإدمن:
1. **عرض الطلبات**: يرى الطلبات المعلقة في تبويب منفصل
2. **المراجعة**: يراجع معلومات الطالب
3. **الموافقة/الرفض**: يختار الموافقة أو الرفض
4. **الإشعار**: يتم إرسال إشعار تلقائياً للطالب

## الملفات المضافة/المحدثة

### ملفات جديدة:
- `lib/pages/pending_approval_page.dart`
- `lib/pages/notifications_page.dart`
- `lib/services/notification_services.dart`
- `lib/pages/widgets/notification_badge.dart`
- `lib/pages/widgets/widget_dialog.dart` (محدث)

### ملفات محدثة:
- `lib/main.dart` - إضافة routes جديدة
- `lib/pages/login_page.dart` - تحسين رسائل الخطأ
- `lib/pages/student_registration_page.dart` - توجيه لصفحة الانتظار
- `lib/providers/user_provider.dart` - تحسين رسائل الخطأ
- `lib/providers/register_provider.dart` - تحسين عملية التسجيل
- `lib/providers/admin_student_provider.dart` - إضافة إشعارات
- `lib/services/login_services.dart` - تحسين التحقق من الحالة
- `lib/services/models_services.dart` - إضافة function للتحقق من الحالة
- `pubspec.yaml` - إضافة dependency للـ intl

## Routes الجديدة:
- `/pending-approval` - صفحة حالة الانتظار
- `/notifications` - صفحة الإشعارات

## الاستخدام

### إضافة Notification Badge:
```dart
NotificationBadge(
  child: IconButton(
    icon: Icon(Icons.notifications),
    onPressed: () => Navigator.pushNamed(context, '/notifications'),
  ),
)
```

### إرسال إشعار:
```dart
await NotificationService.notifyStudentApproval('اسم الطالب');
```

### التحقق من حالة الطالب:
```dart
final isApproved = await checkStudentApprovalStatus('username');
```

## ملاحظات تقنية:
- جميع الإشعارات محفوظة محلياً باستخدام SharedPreferences
- يتم تحديث واجهة المستخدم تلقائياً عند تغيير الحالة
- النظام يدعم اللغة العربية بالكامل
- التصميم متجاوب ومتوافق مع Material Design 