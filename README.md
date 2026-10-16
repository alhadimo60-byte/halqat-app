# حلقات القربات

تطبيق Flutter لإدارة حلقات القرآن الكريم والتعليم الشرعي، ويمكن نشر نسخة الويب مجانًا على Cloudflare Workers.

## النشر على حساب Cloudflare عبر GitHub Actions

1. أنشئ قاعدة D1 باسم `halqat-app-db` في الحساب الذي أرسلته، ثم انسخ معرّف قاعدة البيانات.
2. أضف متغير المستودع `CLOUDFLARE_D1_DATABASE_ID` بمعرّف D1 من **Settings → Secrets and variables → Actions → Variables**.
3. أضف سر المستودع `CLOUDFLARE_API_TOKEN` من صفحة **Secrets**. أنشئ الرمز في الحساب المستهدف، وامنحه صلاحيات **Workers Scripts: Edit** و**D1: Edit** لذلك الحساب فقط.
4. ادفع التغييرات إلى فرع `main` أو `master`، أو شغّل سير العمل **Deploy to Cloudflare Workers** يدويًا من تبويب Actions.

يبني سير العمل التطبيق، ويشغّل التحليل والاختبارات، ويطبّق ترحيلات D1، ثم ينشر `build/web` وواجهة API على Workers. أُعدّ المشروع للحساب الذي أرسلته، وسيكون العنوان `https://halqat-app.husseinalhadi21.workers.dev` إذا كان هذا النطاق الفرعي مفعّلًا. لا تضع رمز Cloudflare أو كلمات المرور في ملفات المشروع أو المستودع؛ أضف رمز API إلى GitHub Secrets فقط.

بعد أول نشر، أضف في **Worker → Settings → Variables and Secrets** سرّي Worker `INITIAL_ADMIN_USERNAME` و`INITIAL_ADMIN_PASSWORD` (كلمة المرور 12 خانة على الأقل). يُنشأ المدير عند أول محاولة دخول، ولا توجد حسابات تجريبية أو تسجيل عام في النسخة السحابية.

ينتج سير العمل أيضًا ملف Android APK متصلًا بواجهة Workers. نزّله من **Actions → آخر تشغيل ناجح → Artifacts → halqat-app-android-apk**. نسخة APK موقعة بمفتاح debug لتسهيل التثبيت والاختبار، وليست مفتاح نشر متجر Google Play.

## البناء والتشغيل محليًا

```sh
flutter pub get
flutter run
```

لبناء الويب محليًا:

```sh
flutter build web --release
```

## التخزين وتسجيل الدخول

النسخة المحلية تحتفظ ببياناتها في الجهاز، أما نسخة Workers فتستخدم D1 وتسجيل دخول بخدمة خلفية وجلسة Cookie آمنة. قاعدة D1 تبدأ ببيانات تجريبية نظيفة، ولا تستورد تلقائيًا محتوى المتصفح. تحديثات القوائم تستخدم رقم مراجعة لمنع الكتابة فوق تغييرات أحدث من جهاز آخر؛ عند ظهور تعارض أعد تحميل التطبيق قبل إعادة المحاولة.
