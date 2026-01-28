# بناء المشروع على Windows (مع إصلاح pub get)

## المتطلبات
- Flutter مفعّل لمنصة Windows:
  - `flutter config --enable-windows-desktop`
  - `flutter doctor` يجب أن يمر بدون أخطاء حرجة

## تثبيت الحزم
إذا ظهر الخطأ "Failed to update packages" أو "authorization failed" أثناء `flutter pub get`:

1) أضف توكن pub.dev (خطوة تفاعلية):
```
dart pub token add https://pub.dev
```
- سيفتح المتصفح، سجّل الدخول ثم انسخ الرمز القصير وألصقه في الطرفية.

2) ثم نفّذ:
```
flutter pub get
flutter analyze
```

3) في حال وجود Proxy/GFW:
```
setx HTTPS_PROXY http://<proxy-host>:<port>
setx HTTP_PROXY http://<proxy-host>:<port>
```
وأعد تشغيل الطرفية ثم:
```
flutter pub get
```

4) تنظيف كاش الحزم (عند الحاجة):
```
flutter pub cache clean
```

## تشغيل وبناء
تشغيل محلي:
```
flutter run -d windows
```

بناء نسخة إنتاج:
```
flutter build windows
```

## ملاحظات
- المشروع يعمل Offline 100% ويستخدم SQLite عبر sqflite_common_ffi، مع ملف قاعدة بيانات داخل مجلد Application Support للمستخدم.
- النسخ الاحتياطي/الاستعادة لقاعدة البيانات يتم بنسخ الملف مباشرة (لا يوجد Cloud).
