// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'سائق زيتون';

  @override
  String get splashNoInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get splashRetry => 'حاول مرة أخرى';

  @override
  String get loginPhoneLabel => 'رقم الهاتف';

  @override
  String get loginPhoneHint => '+9627xxxxxxxx';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginPhoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get loginPhoneInvalid => 'أدخل رقم هاتف صحيح';

  @override
  String get loginPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get loginPasswordTooShort =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get loginFailed =>
      'فشل تسجيل الدخول — تحقق من رقم الهاتف وكلمة المرور';

  @override
  String get loginUnexpectedResponse =>
      'استجابة غير متوقعة من الخادم. يرجى المحاولة مرة أخرى.';

  @override
  String get tabLive => 'الحالية';

  @override
  String get tabHistory => 'السجل';

  @override
  String get tabSettings => 'الإعدادات';

  @override
  String get liveTitle => 'الطلبات الحالية';

  @override
  String get liveEmpty => 'لا توجد طلبات حالية';

  @override
  String get liveError => 'تعذّر تحميل الطلبات — اسحب للتحديث';

  @override
  String get liveNewBadge => 'جديد';

  @override
  String get liveView => 'عرض';

  @override
  String get liveStartDelivery => 'بدء التوصيل';

  @override
  String get liveStartDeliveryFailed => 'تعذّر بدء التوصيل';

  @override
  String get liveMarkDelivered => 'تم التسليم';

  @override
  String get liveMarkDeliveredFailed => 'تعذّر تحديد الطلب كمُسلَّم';

  @override
  String get liveAssignedJustNow => 'تم الإسناد للتو';

  @override
  String liveAssignedMinutesAgo(int minutes) {
    return 'تم الإسناد قبل $minutes دقيقة';
  }

  @override
  String liveAssignedHoursAgo(int hours) {
    return 'تم الإسناد قبل $hours ساعة';
  }

  @override
  String get historyTitle => 'السجل';

  @override
  String get historyEmpty => 'لا توجد عمليات تسليم بعد';

  @override
  String get historyError => 'تعذّر تحميل السجل — اسحب للتحديث';

  @override
  String get orderDetailsTitle => 'تفاصيل الطلب';

  @override
  String get orderDetailsLoadError => 'تعذّر تحميل تفاصيل الطلب';

  @override
  String get orderDetailsPickup => 'الاستلام';

  @override
  String get orderDetailsDeliveryTo => 'التسليم إلى';

  @override
  String get orderDetailsDriver => 'السائق';

  @override
  String get orderDetailsItems => 'الأصناف';

  @override
  String get orderDetailsNoItems => 'لا تتوفر تفاصيل الأصناف';

  @override
  String get orderDetailsNote => 'ملاحظة';

  @override
  String get orderDetailsDeliveryFee => 'رسوم التوصيل';

  @override
  String get orderDetailsTotalToCollect => 'المبلغ المطلوب تحصيله';

  @override
  String get orderDetailsCall => 'اتصال';

  @override
  String get orderDetailsNavigate => 'التوجيه';

  @override
  String get orderDetailsDelivered => 'تم التسليم';

  @override
  String orderDetailsDeliveredAt(String time) {
    return 'تم التسليم $time';
  }

  @override
  String get orderDetailsCustomer => 'العميل';

  @override
  String get orderDetailsNoLocation => 'لا يوجد موقع متاح لهذا الطلب';

  @override
  String get orderDetailsMapsFailed => 'تعذّر فتح الخرائط';

  @override
  String get orderDetailsDialerFailed => 'تعذّر فتح تطبيق الهاتف';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsProfile => 'الملف الشخصي';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsHelp => 'المساعدة';

  @override
  String get settingsAbout => 'عن التطبيق';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsLogoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get settingsLogoutConfirmBody =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى لعرض طلباتك.';

  @override
  String get settingsCancel => 'إلغاء';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileNone => 'لا تتوفر بيانات الملف الشخصي';

  @override
  String get profileName => 'الاسم';

  @override
  String get profilePhone => 'الهاتف';

  @override
  String get profileStatus => 'حالة الحساب';

  @override
  String get profileActive => 'نشط';

  @override
  String get profileInactive => 'غير نشط';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get helpTitle => 'المساعدة';

  @override
  String get helpGettingOrderTitle => 'استلام الطلبات';

  @override
  String get helpGettingOrderBody =>
      'يتم إسناد الطلبات إليك من قِبل فريق التوزيع، وستظهر في تبويب الطلبات الحالية.';

  @override
  String get helpMarkDeliveredTitle => 'تحديد الطلب كمُسلَّم';

  @override
  String get helpMarkDeliveredBody =>
      'افتح الطلب من تبويب الطلبات الحالية واضغط «تم التسليم» بعد تسليمه إلى العميل.';

  @override
  String get helpMoreTitle => 'بحاجة إلى مساعدة إضافية؟';

  @override
  String get helpMoreBody => 'تواصل مع مسؤول التوزيع مباشرة في الوقت الحالي.';

  @override
  String get aboutTitle => 'عن التطبيق';

  @override
  String aboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get aboutPrivacyTitle => 'سياسة الخصوصية';

  @override
  String get aboutPrivacyBody =>
      'نص سياسة الخصوصية مؤقت — استبدله بالسياسة الفعلية قبل الإصدار.';

  @override
  String get aboutTermsTitle => 'شروط الخدمة';

  @override
  String get aboutTermsBody =>
      'نص الشروط مؤقت — استبدله بالشروط الفعلية قبل الإصدار.';
}
