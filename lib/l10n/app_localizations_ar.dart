// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مونديال';

  @override
  String get appNameManager => 'مدير';

  @override
  String get appTagline => 'إدارة الحشود لكأس العالم 2026';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'يرجى إدخال بيانات حسابك.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get orRegisterWith => 'أو سجّل باستخدام';

  @override
  String get googleSignInComingSoon => 'تسجيل الدخول بجوجل قريبًا';

  @override
  String get facebookSignInComingSoon => 'تسجيل الدخول بفيسبوك قريبًا';

  @override
  String get appleSignInComingSoon => 'تسجيل الدخول بآبل قريبًا';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get registerLink => 'سجّل الآن';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordDesc =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور.';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get sendLinkButton => 'إرسال الرابط';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get createAccountTitle => 'إنشاء حسابك';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get nameHint => 'أدخل اسمك الكامل';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get selectRoleLabel => 'اختر دورك';

  @override
  String get selectRoleHint => 'اختر الدور';

  @override
  String get roleFan => 'مشجع';

  @override
  String get roleOrganizer => 'منظم الفعاليات';

  @override
  String get roleSecurity => 'فريق الأمن';

  @override
  String get roleEmergency => 'خدمات الطوارئ';

  @override
  String get registerButton => 'تسجيل';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get loginLink => 'تسجيل الدخول';

  @override
  String get passwordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get pleaseSelectRole => 'يرجى اختيار دور';

  @override
  String get registrationSuccess => 'تم التسجيل بنجاح!';

  @override
  String get registrationFailed => 'فشل التسجيل';

  @override
  String get nameRequired => 'يرجى إدخال اسمك';

  @override
  String get nameMinLength => 'يجب أن يكون الاسم حرفين على الأقل';

  @override
  String get emailRequired => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get emailInvalid => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get passwordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get confirmPasswordRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get roleRequired => 'يرجى اختيار دور';

  @override
  String get verifyEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get emailSentTo => 'أرسلنا رسالة تحقق إلى:';

  @override
  String get verifyEmailInstructions =>
      'يرجى التحقق من صندوق الوارد والنقر على رابط التحقق لتفعيل حسابك. إذا لم تجد الرسالة، تحقق من مجلد البريد العشوائي.';

  @override
  String get verifyAndContinue => 'تم التحقق، متابعة';

  @override
  String get checkingStatus => 'جارٍ التحقق...';

  @override
  String get resendEmail => 'إعادة إرسال رسالة التحقق';

  @override
  String resendEmailCooldown(int seconds) {
    return 'إعادة الإرسال ($seconds ث)';
  }

  @override
  String canResendIn(int seconds) {
    return 'يمكنك إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get verifyEmailHelp =>
      'هل تواجه مشكلة؟ تأكد من التحقق من مجلد البريد العشوائي. قد تستغرق الرسالة بضع دقائق للوصول.';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get emailNotVerified =>
      'لم يتم التحقق من البريد بعد. يرجى التحقق من صندوق الوارد.';

  @override
  String get verificationCheckError => 'خطأ في التحقق من حالة التأكيد';

  @override
  String get emailSentSuccess => 'تم إرسال رسالة التحقق!';

  @override
  String get emailSendFailed =>
      'فشل إرسال رسالة التحقق. يرجى المحاولة مرة أخرى.';

  @override
  String get selectYourRole => 'اختر دورك';

  @override
  String get chooseYourRole => 'اختر دورك';

  @override
  String get selectRoleDescription => 'اختر الدور الذي يصف مستوى وصولك';

  @override
  String get roleFanDesc =>
      'عرض خرائط الملاعب واستقبال تنبيهات السلامة والتنقل بكفاءة';

  @override
  String get roleOrganizerDesc =>
      'مراقبة الحشود وإرسال التنبيهات وإدارة الموظفين وعرض التحليلات';

  @override
  String get roleSecurityDesc =>
      'الإبلاغ عن الحوادث ومراقبة المناطق وتنسيق الاستجابة';

  @override
  String get roleEmergencyDesc =>
      'عرض مواقع الحوادث وتحديث حالة الاستجابة والتواصل';

  @override
  String get continueButton => 'متابعة';

  @override
  String welcomeUser(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get currentEvent => 'الحدث الحالي:';

  @override
  String get noActiveEvent => 'لا يوجد حدث نشط';

  @override
  String get activeAlerts => 'التنبيهات النشطة';

  @override
  String get viewAllAlerts => 'عرض جميع التنبيهات';

  @override
  String get viewMap => 'عرض الخريطة';

  @override
  String get viewAlerts => 'عرض التنبيهات';

  @override
  String get reportIncident => 'الإبلاغ عن حادثة';

  @override
  String get locationSharingOn => 'مشاركة الموقع: مُفعّلة';

  @override
  String get shareMyLocation => 'مشاركة موقعي';

  @override
  String get homeTab => 'الرئيسية';

  @override
  String get mapTab => 'الخريطة';

  @override
  String get alertsTab => 'التنبيهات';

  @override
  String get profileTab => 'الملف الشخصي';

  @override
  String get viewOnMap => 'عرض على الخريطة';

  @override
  String get eventMap => 'خريطة الحدث';

  @override
  String get liveCrowdMonitoring => 'مراقبة الحشود المباشرة';

  @override
  String get averageDensity => 'متوسط الكثافة';

  @override
  String currentAvgDensity(int percent) {
    return 'متوسط الكثافة الحالي';
  }

  @override
  String activeCriticalAlerts(int count) {
    return 'تنبيهات حرجة نشطة: $count';
  }

  @override
  String get allFilter => 'الكل';

  @override
  String get reportIssue => 'إبلاغ عن مشكلة';

  @override
  String get densitySafe => 'آمن (<1.5)';

  @override
  String get densityModerate => 'متوسط';

  @override
  String get densityHigh => 'مرتفع';

  @override
  String get densityCritical => 'حرج (>4.5)';

  @override
  String get populationLabel => 'عدد الأشخاص';

  @override
  String get occupancyLabel => 'نسبة الإشغال';

  @override
  String get densityLabel => 'الكثافة';

  @override
  String get temperatureLabel => 'درجة الحرارة';

  @override
  String get weatherLabel => 'الطقس';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get statusSafe => 'آمن';

  @override
  String get statusModerate => 'متوسط';

  @override
  String get statusHighDensity => 'كثافة عالية';

  @override
  String get statusCritical => 'حرج';

  @override
  String get peopleAlerts => 'تنبيهات الحشود';

  @override
  String get noAlertsTitle => 'لا توجد تنبيهات حاليًا';

  @override
  String get noAlertsSubtitle => 'سيتم إعلامك بأي تحديثات للسلامة';

  @override
  String get activeFilter => 'نشط';

  @override
  String get resolvedFilter => 'تم الحل';

  @override
  String get criticalLabel => 'حرج';

  @override
  String get highLabel => 'مرتفع';

  @override
  String get moderateLabel => 'متوسط';

  @override
  String get infoLabel => 'معلومات';

  @override
  String get resolvedLabel => 'تم الحل';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String hoursAgo(int hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String daysAgo(int days) {
    return 'منذ $days يوم';
  }

  @override
  String get severityLabel => 'مستوى الخطورة';

  @override
  String get affectedZone => 'المنطقة المتأثرة';

  @override
  String get allZones => 'جميع المناطق';

  @override
  String get acknowledgeButton => 'تأكيد الاستلام';

  @override
  String get notifyEmergency => 'إبلاغ الطوارئ';

  @override
  String get markResolved => 'تم الحل';

  @override
  String get alertAcknowledged => 'تم تأكيد استلام التنبيه';

  @override
  String get alertAcknowledgeFailed => 'فشل تأكيد استلام التنبيه';

  @override
  String get emergencyNotified => 'تم إبلاغ فريق الطوارئ';

  @override
  String get emergencyNotifyFailed => 'فشل إبلاغ فريق الطوارئ';

  @override
  String get alertResolved => 'تم حل التنبيه';

  @override
  String get alertResolveFailed => 'فشل حل التنبيه';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get displayPreferences => 'تفضيلات العرض';

  @override
  String get notificationsAlerts => 'الإشعارات والتنبيهات';

  @override
  String get languageLocalization => 'اللغة والتعريب';

  @override
  String get privacyAccount => 'الخصوصية والحساب';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get doneButton => 'تم';

  @override
  String get restoreDefaults => 'استعادة الإعدادات الافتراضية';

  @override
  String get seedDemoData => 'تحميل البيانات التجريبية';

  @override
  String get securedByFirebase => 'مؤمن بواسطة Firebase';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get darkModeSubtitle => 'استخدام السمة الداكنة في جميع أنحاء التطبيق';

  @override
  String get textSize => 'حجم النص';

  @override
  String get textSizeSmall => 'صغير';

  @override
  String get textSizeMedium => 'متوسط';

  @override
  String get textSizeLarge => 'كبير';

  @override
  String get pushNotifications => 'الإشعارات الفورية';

  @override
  String get pushNotificationsSubtitle => 'استقبال الإشعارات على جهازك';

  @override
  String get soundLabel => 'الصوت';

  @override
  String get soundSubtitle => 'تشغيل صوت للتنبيهات الجديدة';

  @override
  String get crowdAlerts => 'تنبيهات الحشود';

  @override
  String get crowdAlertsSubtitle => 'إشعارات عن تغيرات كثافة الحشود';

  @override
  String get emergencyAlerts => 'تنبيهات الطوارئ';

  @override
  String get emergencyAlertsSubtitle => 'استقبال إشعارات الطوارئ الحرجة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get locationSharing => 'مشاركة الموقع';

  @override
  String get locationSharingSubtitle => 'مشاركة موقعك لتتبع الحشود';

  @override
  String get analyticsLabel => 'التحليلات';

  @override
  String get analyticsSubtitle => 'المساعدة في تحسين التطبيق ببيانات الاستخدام';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirm =>
      'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات بنجاح';

  @override
  String get settingsRestored => 'تم استعادة الإعدادات الافتراضية';

  @override
  String get seedDataTitle => 'تحميل البيانات التجريبية';

  @override
  String get seedDataDesc =>
      'سيؤدي هذا إلى مسح البيانات الحالية وتحميل بيانات تجريبية جديدة (أحداث، مناطق، كثافة حشود، حوادث، تنبيهات، إلخ).\n\nسيتم تسجيل خروجك وستحتاج لتسجيل الدخول مرة أخرى.';

  @override
  String get seedDataButton => 'تحميل البيانات';

  @override
  String seedingFailed(String error) {
    return 'فشل التحميل: $error';
  }

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get logoutButton => 'تسجيل الخروج';

  @override
  String get sendAlertTitle => 'إرسال تنبيه';

  @override
  String get alertTitleLabel => 'عنوان التنبيه';

  @override
  String get alertTitleHint => 'مثال: تغيير إغلاق البوابة';

  @override
  String get messageLabel => 'الرسالة';

  @override
  String get messageHint => 'وصف التنبيه...';

  @override
  String get recipientLabel => 'المستلم';

  @override
  String get recipientHint => 'اختر المستلم';

  @override
  String get allUsers => 'جميع المستخدمين';

  @override
  String get fansOnly => 'المشجعون فقط';

  @override
  String get securityTeam => 'فريق الأمن';

  @override
  String get emergencyServices => 'خدمات الطوارئ';

  @override
  String get sendAlertButton => 'إرسال التنبيه';

  @override
  String get alertSentSuccess => 'تم إرسال التنبيه بنجاح!';

  @override
  String get analyticsTitle => 'التحليلات';

  @override
  String get totalIncidents => 'إجمالي الحوادث';

  @override
  String get avgResponse => 'متوسط الاستجابة';

  @override
  String get peakAttendance => 'ذروة الحضور';

  @override
  String get alertsSent => 'التنبيهات المرسلة';

  @override
  String get crowdDensityOverTime => 'كثافة الحشود عبر الزمن';

  @override
  String get crowdDensitySubtitle => 'متوسط الأشخاص لكل م² بالساعة';

  @override
  String get noDensityData => 'لا توجد بيانات كثافة';

  @override
  String get incidentsByType => 'الحوادث حسب النوع';

  @override
  String get totalIncidentsBreakdown => 'إجمالي تفصيل الحوادث';

  @override
  String get noIncidentData => 'لا توجد بيانات حوادث';

  @override
  String get medicalType => 'طبي';

  @override
  String get securityType => 'أمني';

  @override
  String get overcrowdingType => 'ازدحام';

  @override
  String get otherType => 'أخرى';

  @override
  String get zoneOccupancyTitle => 'توزيع إشغال المناطق';

  @override
  String get zoneOccupancySubtitle => 'متوسط الكثافة حسب المنطقة';

  @override
  String get noZoneData => 'لا توجد بيانات مناطق';

  @override
  String get staffManagement => 'إدارة الموظفين';

  @override
  String get allStaffTab => 'جميع الموظفين';

  @override
  String get assignmentsTab => 'التعيينات';

  @override
  String get zonesTab => 'المناطق';

  @override
  String get noStaffFound => 'لم يتم العثور على موظفين';

  @override
  String get noStaffDesc => 'سيظهر هنا موظفو الأمن والطوارئ';

  @override
  String get staffOverview => 'نظرة عامة على الموظفين';

  @override
  String get assignedLabel => 'معيّن';

  @override
  String get availableLabel => 'متاح';

  @override
  String get assignStaffTitle => 'تعيين موظف';

  @override
  String get selectZoneLabel => 'اختر المنطقة';

  @override
  String get chooseZoneHint => 'اختر منطقة';

  @override
  String staffCount(int count) {
    return '$count موظف';
  }

  @override
  String get assignToZone => 'تعيين في المنطقة';

  @override
  String staffAssignedSuccess(String name, String zone) {
    return 'تم تعيين $name في $zone';
  }

  @override
  String get staffAssignmentFailed => 'فشل تعيين الموظف';

  @override
  String get noAssignments => 'لا توجد تعيينات نشطة';

  @override
  String get assignStaffInstructions =>
      'عيّن الموظفين في المناطق من تبويب جميع الموظفين';

  @override
  String get assignmentRemoved => 'تم إزالة المهمة';

  @override
  String get assignmentRemovalFailed => 'فشل إزالة التعيين';

  @override
  String get reassignButton => 'إعادة تعيين';

  @override
  String get assignButton => 'تعيين';

  @override
  String get noZonesFound => 'لم يتم العثور على مناطق';

  @override
  String get noZonesDesc => 'ستظهر المناطق عند تحميل بيانات الحدث';

  @override
  String get securityDashboard => 'لوحة الأمن';

  @override
  String get onDuty => 'في الخدمة';

  @override
  String get offDuty => 'خارج الخدمة';

  @override
  String get monitorCrowd => 'مراقبة الحشود';

  @override
  String get incidentTypeLabel => 'نوع الحادثة';

  @override
  String get selectTypeHint => 'اختر النوع';

  @override
  String get crowdIssue => 'مشكلة حشود';

  @override
  String get medicalEmergency => 'حالة طبية طارئة';

  @override
  String get securityThreat => 'تهديد أمني';

  @override
  String get fireHazard => 'خطر حريق';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get descriptionHint => 'أدخل تفاصيل الحادثة...';

  @override
  String get attachImage => 'إرفاق صورة';

  @override
  String get incidentSentText => 'تم إرسال الحادثة لفريق الأمن.';

  @override
  String get submitReport => 'إرسال التقرير';

  @override
  String get incidentReportedSuccess => 'تم الإبلاغ عن الحادثة بنجاح!';

  @override
  String get emergencyDashboard => 'لوحة الطوارئ';

  @override
  String get dispatchButton => 'إرسال فريق';

  @override
  String get evacuateButton => 'إخلاء';

  @override
  String get reportIncidentTitle => 'الإبلاغ عن حادثة';

  @override
  String get incidentTypeSection => 'نوع الحادثة';

  @override
  String get severityLevelSection => 'مستوى الخطورة';

  @override
  String get descriptionSection => 'الوصف';

  @override
  String get photosSection => 'الصور (اختياري)';

  @override
  String get facilityType => 'مرافق';

  @override
  String get lowSeverity => 'منخفض';

  @override
  String get mediumSeverity => 'متوسط';

  @override
  String get highSeverity => 'مرتفع';

  @override
  String get criticalSeverity => 'حرج';

  @override
  String get describeIncident => 'صِف ما حدث...';

  @override
  String get addPhotos => 'إضافة صور';

  @override
  String photosAdded(int count) {
    return '$count/3 صور مضافة';
  }

  @override
  String get cameraOption => 'الكاميرا';

  @override
  String get galleryOption => 'المعرض';

  @override
  String get imagePickFailed => 'فشل اختيار الصورة';

  @override
  String get descriptionRequired => 'يرجى وصف الحادثة';

  @override
  String get incidentReportSuccess => 'تم الإبلاغ عن الحادثة بنجاح';

  @override
  String get incidentReportFailed => 'فشل الإبلاغ عن الحادثة';

  @override
  String get communicationHub => 'مركز الاتصالات';

  @override
  String get channelsSection => 'القنوات';

  @override
  String get noChannels => 'لا توجد قنوات متاحة';

  @override
  String get selectChannel => 'اختر قناة لبدء المراسلة';

  @override
  String messageCount(int count) {
    return '$count رسالة';
  }

  @override
  String get noMessages => 'لا توجد رسائل بعد';

  @override
  String get startConversation => 'ابدأ المحادثة';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get lastUpdated => 'آخر تحديث: يناير 2026';

  @override
  String get introductionSection => 'مقدمة';

  @override
  String get dataCollectionSection => '1. جمع البيانات';

  @override
  String get consentSection => '2. الموافقة ومشاركة الموقع';

  @override
  String get gdprRightsSection => '3. حقوقك (التوافق مع GDPR)';

  @override
  String get dataRetentionSection => '4. الاحتفاظ بالبيانات';

  @override
  String get securityMeasuresSection => '5. إجراءات الأمان';

  @override
  String get thirdPartySection => '6. خدمات الطرف الثالث';

  @override
  String get contactInfoSection => '7. معلومات الاتصال';

  @override
  String get policyChangesSection => '8. التغييرات على هذه السياسة';

  @override
  String get errorGeneric => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNetwork => 'خطأ في الشبكة. يرجى التحقق من اتصالك.';

  @override
  String get errorInvalidEmail => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get errorInvalidPassword =>
      'يجب أن تكون كلمة المرور 8 أحرف على الأقل مع حرف كبير ورقم واحد.';

  @override
  String get errorLoginFailed => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorEmptyField => 'هذا الحقل لا يمكن أن يكون فارغًا.';

  @override
  String get errorAccountLocked =>
      'تم قفل الحساب مؤقتًا بسبب محاولات فاشلة كثيرة. حاول لاحقًا.';

  @override
  String get errorEmailNotVerified =>
      'يرجى التحقق من بريدك الإلكتروني قبل تسجيل الدخول.';

  @override
  String get successLogin => 'تم تسجيل الدخول بنجاح!';

  @override
  String get successRegister =>
      'تم التسجيل بنجاح! يرجى التحقق من بريدك الإلكتروني.';

  @override
  String get successAlertSent => 'تم إرسال التنبيه بنجاح!';

  @override
  String get successIncidentReported => 'تم الإبلاغ عن الحادثة بنجاح!';

  @override
  String get successStatusUpdated => 'تم تحديث الحالة بنجاح!';

  @override
  String get successEmailVerification =>
      'تم إرسال رسالة التحقق. يرجى التحقق من صندوق الوارد.';

  @override
  String get congestionAlert => 'تنبيه ازدحام';

  @override
  String get safetyAlert => 'تنبيه سلامة';

  @override
  String get emergencyAlert => 'تنبيه طوارئ';

  @override
  String get informationAlert => 'معلومات';

  @override
  String capacityPercent(int percent) {
    return '$percent% من السعة';
  }

  @override
  String peoplePerSqm(String value) {
    return '$value شخص/م²';
  }

  @override
  String degreeCelsius(String temp) {
    return '$temp درجة مئوية';
  }

  @override
  String get totalPopulation => 'إجمالي الحضور';

  @override
  String get totalCapacity => 'السعة الإجمالية';

  @override
  String get overallOccupancy => 'نسبة الإشغال الكلية';

  @override
  String get criticalZones => 'المناطق الحرجة';

  @override
  String get highDensityZones => 'مناطق الكثافة العالية';

  @override
  String get safeZonesLabel => 'المناطق الآمنة';

  @override
  String get avgDensityLabel => 'متوسط الكثافة';

  @override
  String get zoneMonitoring => 'مراقبة المناطق';

  @override
  String get noZoneDataAvailable => 'لا توجد بيانات مناطق';

  @override
  String get createEvent => 'إنشاء حدث';

  @override
  String get searchEvents => 'بحث في الأحداث';

  @override
  String get managedEvents => 'الأحداث المُدارة';

  @override
  String get noEventsFound => 'لم يتم العثور على أحداث';

  @override
  String get eventActive => 'نشط';

  @override
  String get eventPlanned => 'مخطط';

  @override
  String get eventCompleted => 'مكتمل';

  @override
  String get attendanceLabel => 'الحضور';

  @override
  String expectedAttendance(int count) {
    return 'المتوقع: $count';
  }

  @override
  String get demoBanner => 'وضع العرض التوضيحي';

  @override
  String get quickLogin => 'تسجيل دخول سريع';

  @override
  String get demoCredentialsLabel => 'حسابات تجريبية';

  @override
  String get tapToLogin => 'اضغط على أي حساب لتسجيل الدخول فورًا';

  @override
  String passwordValidation(int min) {
    return 'يجب أن تكون كلمة المرور $min أحرف على الأقل.';
  }

  @override
  String passwordMaxLength(int max) {
    return 'يجب أن تكون كلمة المرور أقل من $max حرف.';
  }

  @override
  String get passwordUppercase =>
      'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل.';

  @override
  String get passwordNumber =>
      'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل.';

  @override
  String nameMinLengthValidation(int min) {
    return 'يجب أن يكون الاسم $min أحرف على الأقل.';
  }

  @override
  String nameMaxLengthValidation(int max) {
    return 'يجب أن يكون الاسم أقل من $max حرف.';
  }

  @override
  String get alertResolvedSnack => 'تم حل التنبيه';

  @override
  String get eventCreatedSuccess => 'تم إنشاء الحدث بنجاح!';

  @override
  String eventCreatedFailed(String error) {
    return 'فشل إنشاء الحدث: $error';
  }

  @override
  String searchingFor(String value) {
    return 'جارٍ البحث عن \"$value\"...';
  }

  @override
  String get incidentAcknowledged => 'تم تأكيد الحادثة';

  @override
  String get teamDispatched => 'تم إرسال الفريق';

  @override
  String get statusOnSite => 'الحالة: في الموقع';

  @override
  String get incidentResolved => 'تم حل الحادثة';

  @override
  String get failedPickImage => 'فشل اختيار الصورة';

  @override
  String errorWithDetails(String error) {
    return 'خطأ: $error';
  }

  @override
  String get textMessage => 'رسالة نصية';

  @override
  String get alertMessage => 'تنبيه';

  @override
  String get incidentUpdate => 'تحديث حادثة';

  @override
  String get seedData => 'تحميل البيانات';

  @override
  String get seedingFailedShort => 'فشل التحميل';

  @override
  String get failedDeleteAccount => 'فشل حذف الحساب';

  @override
  String passwordResetSent(String email) {
    return 'تم إرسال رابط إعادة تعيين كلمة المرور إلى $email';
  }

  @override
  String get initiateEvacuation => 'بدء الإخلاء؟';

  @override
  String get evacuationSentSuccess => 'تم إرسال تنبيه الإخلاء لجميع المستخدمين';

  @override
  String get evacuationFailed => 'فشل إرسال تنبيه الإخلاء';

  @override
  String get nameCannotBeEmpty => 'لا يمكن أن يكون الاسم فارغًا';

  @override
  String get fillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get passwordMinChars =>
      'يجب أن تكون كلمة المرور الجديدة 8 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور الجديدتان غير متطابقتين';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get deleteButton => 'حذف';

  @override
  String get passwordResetFailed => 'فشل في إرسال بريد إعادة التعيين';

  @override
  String get yourEmail => 'بريدك الإلكتروني';

  @override
  String get selectChannelToMessage => 'اختر قناة لبدء المراسلة';

  @override
  String get sendingAsAlert => 'إرسال كتنبيه';

  @override
  String get sendingAsIncidentUpdate => 'إرسال كتحديث حادث';

  @override
  String get channel => 'قناة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get securityAndEmergencyStaffWillAppear =>
      'سيظهر موظفو الأمن والطوارئ هنا';

  @override
  String get failedToAssignStaff => 'فشل في تعيين الموظفين';

  @override
  String get security => 'الأمن';

  @override
  String get emergency => 'الطوارئ';

  @override
  String get noActiveAssignments => 'لا توجد مهام نشطة';

  @override
  String get assignStaffToZones =>
      'عين الموظفين للمناطق من علامة التبويب جميع الموظفين';

  @override
  String get failedToRemoveAssignment => 'فشل في إزالة المهمة';

  @override
  String get zonesWillAppearOnceEventDataLoaded =>
      'ستظهر المناطف بمجرد تحميل بيانات الحدث';

  @override
  String get safeDensity => 'آمن (<1.5)';

  @override
  String get moderateDensity => 'معتدل';

  @override
  String get highDensity => 'عالي';

  @override
  String get criticalDensity => 'حرج (>4.5)';

  @override
  String get failedSendEvacuationAlert => 'فشل في إرسال تنبيه الإخلاء';

  @override
  String get activeEvents => 'الأحداث النشطة';

  @override
  String get crowdZones => 'مناطق الحشود';

  @override
  String get alerts => 'التنبيهات';

  @override
  String get incidents => 'الحوادث';

  @override
  String get currentEventLabel => 'الحدث الحالي:';

  @override
  String get liveEventStatus => 'مباشر';

  @override
  String get upcomingEventStatus => 'قادم';

  @override
  String get endedEventStatus => 'انتهى';

  @override
  String get organizerDashboard => 'لوحة تحكم المنظم';

  @override
  String get liveEventMap => 'خريطة الحدث المباشر';

  @override
  String get createEventButton => 'إنشاء حدث';

  @override
  String get eventTitleLabel => 'اسم الحدث';

  @override
  String get eventTitleHint => 'مثال، كأس العالم - مرحلة المجموعات';

  @override
  String get eventDescriptionLabel => 'الوصف';

  @override
  String get eventDescriptionHint => 'صف الحدث...';

  @override
  String get searchLabel => 'بحث';

  @override
  String get searchHint => 'البحث عن أحداث، مناطق، تنبيهات...';

  @override
  String get quickAccess => 'وصول سريع';

  @override
  String get incidentSentToSecurity => 'تم إرسال الحادث إلى فريق الأمن.';

  @override
  String get viewAlertsButton => 'عرض التنبيهات';

  @override
  String get teamUpdatesButton => 'تحديثات الفريق';

  @override
  String get activeAlertsTitle => 'التنبيهات النشطة';

  @override
  String get noActiveAlerts => 'لا توجد تنبيهات نشطة';

  @override
  String get criticalDensityStatus => 'حرج';

  @override
  String get highDensityStatus => 'كثافة عالية';

  @override
  String get normalDensityStatus => 'طبيعي';

  @override
  String get capacityLabel => '% السعة';

  @override
  String currentAvgDensityValue(Object value) {
    return '$value متوسط الكثافة';
  }

  @override
  String get aboveRecommended => 'فوق الموصى به';

  @override
  String get reportButtonShort => 'تقرير...';

  @override
  String get viewAlertsShort => 'عرض ت...';

  @override
  String get emergencyTitle => 'طوارئ';

  @override
  String get evacuationWarning =>
      'سيؤدي هذا إلى تشغيل تنبيه الإخلاء لجميع الحاضرين والموظفين في المكان. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get evacuationOrderMessage =>
      'أمر الإخلاء: يجب على جميع الحاضرين والموظفين إخلاء المكان فوراً. اتبع طرق الطوارئ للخروج.';

  @override
  String minutesAgoShort(Object minutes) {
    return '$minutesد مضت';
  }

  @override
  String get allIncidentsTitle => 'جميع الحوادث';

  @override
  String get noActiveIncidents => 'لا توجد حوادث نشطة';

  @override
  String get allEmergenciesResolved => 'تم حل جميع الحالات الطارئة';
}
