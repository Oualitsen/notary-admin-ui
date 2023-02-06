import 'app_localizations.dart';

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'CONTROLE';

  @override
  String get logout => 'تسجيل خروج';

  @override
  String get confirm => 'تأكيد';

  @override
  String get confirmLogout => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get no => 'لا';

  @override
  String get yes => 'نعم';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get password => 'كلمه السر';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get requiredField => 'هذه الخانة مطلوبه';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'موافق';

  @override
  String get edit => 'تعديل';

  @override
  String get camera => 'الة تصوير';

  @override
  String get gallery => 'صالة عرض';

  @override
  String get iDontHaveAnAccount => 'ليس لدي حساب';

  @override
  String get register => 'اشتراك';

  @override
  String get repeatPassword => 'أعد كلمة السر الخاصة بك';

  @override
  String get next => 'التالي';

  @override
  String get passwordDontMatch => 'كلمات المرور غير متطابقة';

  @override
  String get firstName => 'الاسم';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get back => 'رجوع';

  @override
  String get save => 'يحفظ';

  @override
  String get email => 'بريد الالكتروني';

  @override
  String get inputEmail => 'إدخال البريد الإلكتروني';

  @override
  String get validate => 'تحقق';

  @override
  String get map => 'خريطة';

  @override
  String get list => 'قائمة';

  @override
  String get editEmail => 'تغيير البريد الالكتروني';

  @override
  String get editInfo => 'تغيير المعلومات';

  @override
  String get profile => 'حساب تعريفي';

  @override
  String get personalInfo => 'معلومات شخصية';

  @override
  String get tapToVerifyYourEmail => 'انقر للتحقق من بريدك الإلكتروني';

  @override
  String get changePassword => 'غير كلمة السر';

  @override
  String get oldPassword => 'كلمة سر القديمة';

  @override
  String get newPassword => 'كلمة السر الجديدة';

  @override
  String get retypePassword => 'أعد إدخال كلمة السر';

  @override
  String get passwordChanged => 'تم تغيير الرقم السري بنجاح';

  @override
  String get forgotPassword => 'نسيت كلمة السر';

  @override
  String get recoverPassword => 'إستعادة كلمة السر';

  @override
  String get inputUsername => 'أدخل اسم المستخدم';

  @override
  String get usernameNotFound => ' لم يتم العثور على اسم المستخدم ';

  @override
  String get address => 'العنوان';

  @override
  String get promotions => 'العروض الترويجية';

  @override
  String get filter => 'تصفية';

  @override
  String get promotionEnds => 'تنتهي';

  @override
  String get promotionStarted => 'تبدأ';

  @override
  String get deliveryAvailable => 'التسليم متاح';

  @override
  String get noMedia => 'لا توجد صور';

  @override
  String get couldNotLoadVideo => 'عذرا لا يمكن تحميل الفيديو';

  @override
  String get couldNotLoadData => 'تعذر تحميل البيانات';

  @override
  String get usePhoneInstead => 'استخدم رقم الهاتف بدلاً من ذلك';

  @override
  String get useEmailInstead => 'استخدم البريد الإلكتروني بدلاً من ذلك';

  @override
  String get phoneVerificationFailedTitle => 'خطأ التحقق';

  @override
  String get phoneVerificationFailedText => 'عذرا لم نتمكن من التحقق من رقم هاتفك';

  @override
  String get invalidCodeTitle => 'الرمز خاطئ';

  @override
  String get invalidCodeText => 'الرمز خاطئ';

  @override
  String get invalidValue => 'قيمة غير صالحة';

  @override
  String get phoneNumberUpdated => 'تم تحديث رقم الهاتف بنجاح';

  @override
  String get invalidEmail => 'بريد إلكتروني خاطئ';

  @override
  String get emailUpdated => 'تم تحديث البريد الإلكتروني بنجاح';

  @override
  String get notFound => '404 Not Found';

  @override
  String get da => 'د.ج';

  @override
  String maxValue(Object value) {
    return 'يجب أن تكون القيمة أقل من أو تساوي $value';
  }

  @override
  String minValue(Object value) {
    return 'يجب أن تكون القيمة أكبر من أو تساوي $value';
  }

  @override
  String get showMore => 'أظهر المزيد';

  @override
  String get categories => 'الفئات';

  @override
  String get selectAll => 'اختر الكل';

  @override
  String get range => 'مدى';

  @override
  String get favorites => 'المفضلة';

  @override
  String get favoritesTitle => 'المفضل';

  @override
  String get favoritesWillAppearHere => 'ستظهر قائمة المفضلة هنا';

  @override
  String get addedToFavorites => 'تمت الإضافة إلى قائمة المفضلة';

  @override
  String get removedFromFavorites => 'تمت إزالته من قائمة المفضلة';

  @override
  String selectedCount(Object value) {
    return '$value المحدد';
  }

  @override
  String get editPhoneNumber => 'تغيير رقم الهاتف';

  @override
  String get send => 'إرسل';

  @override
  String get stores => 'المتاجر';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get termsAndConditions => 'الأحكام والشروط';

  @override
  String get search => 'بحث';

  @override
  String get searchStoreByName => 'اسم المحل';

  @override
  String get noStores => 'لا توجد متاجر';

  @override
  String get promotionsAndOffers => 'الترقيات والعروض';

  @override
  String get toTime => 'إلى';

  @override
  String get customerName => 'اسم الزبون';

  @override
  String get newCustomer => 'زبون جديد';

  @override
  String get editCustomer => ' تعديل الزبون';

  @override
  String get street => 'شارع';

  @override
  String get city => 'مدينة';

  @override
  String get state => 'ولاية';

  @override
  String get country => 'دولة';

  @override
  String get postalCode => 'رمز بريدي';

  @override
  String get coordinates => 'إحداثيات';

  @override
  String get newAgentType => ' نوع الحارس جديد';

  @override
  String get agentTypeName => 'نوع الحارس';

  @override
  String get agentTypeDescription => '  وصف نوع الحارس';

  @override
  String get newSite => 'موقع جديد';

  @override
  String get siteName => 'اسم الموقع';

  @override
  String get startTime => 'وقت البدء';

  @override
  String get endttime => 'وقت النهاية';

  @override
  String get newAgent => 'حارس جديد';

  @override
  String get agentType => 'نوع الحارس';

  @override
  String get socialSecurity => 'ضمان اجتماعي';

  @override
  String get value => 'قيمة';

  @override
  String get expiryDate => 'تاريخ انتهاء الصلاحية';

  @override
  String get language => 'لغة';

  @override
  String get newContract => 'عقد جديد';

  @override
  String get hoursPerMonth => 'عدد الساعات في الشهر';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get selectAgentTypes => 'اختار انواع الحراس';

  @override
  String get selectAgentType => 'اختار نوع الحارس';

  @override
  String get addContacts => 'اضف جهات اتصال';

  @override
  String get contactName => 'اسم جهة الاتصال';

  @override
  String get contactValue => 'قيمة الاتصال';

  @override
  String get contactNameEx => 'Website, email...';

  @override
  String get newContact => 'جهة اتصال جديدة';

  @override
  String get newHoliday => 'عطلة جديدة';

  @override
  String get newPlanification => 'تخطيط جديد';

  @override
  String get planificationStatus => 'حالة التخطيط';

  @override
  String get selectThePlanificationStatus => 'حدد حالة التخطيط';

  @override
  String get invalidDateRange => 'النطاق الزمني غير صالح!';

  @override
  String get selectSite => 'اختار موقع';

  @override
  String get addAgentType => 'أضف نوع الحراس';

  @override
  String get notes => 'ملحوظات';

  @override
  String get selectAgent => 'اختار حارس';

  @override
  String get createdsuccssfully => 'تم إنشاؤه بنجاح';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get gender => 'جنس';

  @override
  String get employmentType => 'نوع التوظيف';

  @override
  String get contractor => 'CONTRACTOR';

  @override
  String get employee => 'موظف';

  @override
  String get agentStatus => ' حالة الحارس';

  @override
  String get active => 'نشيط';

  @override
  String get selectCustomer => 'اختار الزبون ';

  @override
  String get agentStatusActive => 'نشيط';

  @override
  String get agentStatusSuspended => 'موقوف عن العمل';

  @override
  String get agentEmploymentTypeContractor => 'Contractor';

  @override
  String get agentEmploymentTypeEmployee => 'موظف';

  @override
  String get addAgentPlanificationRelation => 'أضف حراس';

  @override
  String get agent => 'الحارس';

  @override
  String get planificationStatusNew => 'جديد';

  @override
  String get planificationStatusDone => 'تم';

  @override
  String get planificationStatusCanceled => 'ملغاة';

  @override
  String get changeRole => 'تغيير الدور ';

  @override
  String get delete => 'حذف ';

  @override
  String get customerList => 'قائمة الزبائن';

  @override
  String get customerDetails => 'تفاصيل الزبون ';

  @override
  String get siteList => 'قائمة المواقع';

  @override
  String get agentList => 'قائمة الحراس';

  @override
  String get customer => 'الزبون';

  @override
  String get name => ' اسم ';

  @override
  String get agentDetails => 'تفاصيل الحارس ';

  @override
  String get siteDetails => 'تفاصيل الموقع';

  @override
  String get contractDetails => ' تفاصيل العقد ';

  @override
  String get noContract => 'لا عقد';

  @override
  String get planificationList => 'قائمة التخطيط';

  @override
  String get planificationDetails => '   تفاصيل التخطيط';

  @override
  String get addPlanification => ' أضف تخطيط';

  @override
  String get selectACustomerFirst => 'الرجاء تحديد زبون أولاً';

  @override
  String get site => 'موقع';

  @override
  String get agentName => 'اسم الحارس';

  @override
  String get start => 'بداية';

  @override
  String get agents => 'الحراس';

  @override
  String get customers => 'زبائن';

  @override
  String get agentTypeList => 'قائمة أنواع الحراس';

  @override
  String get agentTypes => 'أنواع الحراس';

  @override
  String get addAgent => 'إضافة حارس';

  @override
  String get addCustomer => 'أضف زبون';

  @override
  String get previous => 'سابق';

  @override
  String get submit => 'إرسال';

  @override
  String get agentInformations => 'معلومات الحارس';

  @override
  String get accountDetails => 'تفاصيل الحساب';

  @override
  String get employementDetails => 'تفاصيل التوظيف';

  @override
  String get selectAgentTypesFirst => 'حدد نوع حارس واحد على الأقل ';

  @override
  String get addAContact => 'أضف جهة اتصال أولاً';

  @override
  String get siteInformations => 'معلومات الموقع';

  @override
  String get contacts => 'جهات الاتصال';

  @override
  String get addSite => 'إضافة موقع';

  @override
  String get customerSites => 'مواقع الزبون';

  @override
  String get noSite => 'لا موقع';

  @override
  String get holidaysHistory => 'تاريخ العطل';

  @override
  String get savedSuccessfully => 'حفظ بنجاح';

  @override
  String get noHolidays => 'لا عطلات';

  @override
  String get editAgentType => 'تعديل نوع الحارس';

  @override
  String get editAgent => 'تعديل الحارس';

  @override
  String get done => 'منتهي';

  @override
  String get editSite => 'تعديل الموقع';

  @override
  String get editContract => 'تعديل العقد';

  @override
  String get editHolidays => 'تعديل العطل';

  @override
  String get pleaseConfirm => 'تأكيد';

  @override
  String get confirmDelete => 'هل أنت متأكد من الحذف ؟';

  @override
  String get createAnIntervention => 'إنشاء تدخل';

  @override
  String get isProCardRequired => 'هل البطاقة المهنية مطلوبة';

  @override
  String get editPlanification => 'تعديل التخطيط';

  @override
  String get selectAnAgent => 'من فضلك ، حدد حارس أولا! ';

  @override
  String get agentNoGeoPoint => 'الحارس ';

  @override
  String get sentAt => 'أرسل على';

  @override
  String get noCustomer => 'لا زبائن ';

  @override
  String get receivedAt => 'استقبل في';

  @override
  String get selectMonth => 'اختر شهرا';

  @override
  String get lastKnownPosition => 'آخر موضع معروف';

  @override
  String get proCardNeeded => 'مطلوب بطاقة احترافية';

  @override
  String get noAgent => 'لا حراس';

  @override
  String get noAgentType => 'لا انواع الحراس';

  @override
  String get workedHours => 'عدد الساعات المعمولة';

  @override
  String get percentage => 'النسبة المئوية';

  @override
  String get reload => 'إعادة تحميل';

  @override
  String get workHours => '';

  @override
  String get siteWorkHours => 'Site\'s Work hours';

  @override
  String get cannotEditPlanification => 'لا يمكنك تعديل هذا التخطيط';

  @override
  String get archive => '';

  @override
  String get confirmCancelPlanification => 'هل أنت متأكد أنك تريد إلغاء هذا التخطيط؟';

  @override
  String get confirmArchivePlanification => '';

  @override
  String get planificationCanceled => 'تم إلغاء التخطيط بنجاح';

  @override
  String get planificationArchieved => '';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get general => 'General';

  @override
  String get dateOfBirth => 'Date Of Birth';

  @override
  String get cardId => 'Id Card';

  @override
  String get frontImageUrl => 'Front image url';

  @override
  String get backImageUrl => 'Back image url';

  @override
  String get idCardInfo => 'Id card info';

  @override
  String get updatedSuccessfully => 'Updated successfully';

  @override
  String get addFileTitle => 'Pick a file';

  @override
  String get editFileName => 'Edit file name';

  @override
  String get newAssistant => 'New assistant';

  @override
  String get credentails => 'Credentails';
}
