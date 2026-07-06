// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'لوت';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSearch => 'البحث';

  @override
  String get navCart => 'السلة';

  @override
  String get navWishlist => 'المفضلة';

  @override
  String get navAccount => 'حسابي';

  @override
  String get heroTitle => 'أيادٍ صغيرة، مغامرات كبيرة';

  @override
  String get heroSubtitle =>
      'ألعاب مختارة لكل عمر، تصلكم في جميع مناطق الكويت.';

  @override
  String get searchHint => 'ابحث عن ألعاب وماركات…';

  @override
  String get shopByAge => 'تسوق حسب العمر';

  @override
  String get shopByCategory => 'تسوق حسب الفئة';

  @override
  String get shopByBrand => 'ماركات شهيرة';

  @override
  String get newArrivals => 'وصل حديثًا';

  @override
  String get bestSellers => 'الأكثر مبيعًا';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get promoBannerTitle => 'خصم 10% على طلبك الأول';

  @override
  String get promoBannerSubtitle => 'استخدم الرمز LOOT10 عند الدفع';

  @override
  String get promoBannerCta => 'تسوق الآن';

  @override
  String greatForAges(String label) {
    return 'مناسب لعمر $label';
  }

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count لعبة',
      few: '$count ألعاب',
      two: 'لعبتان',
      one: 'لعبة واحدة',
      zero: 'لا توجد ألعاب',
    );
    return '$_temp0';
  }

  @override
  String get noResults => 'لا توجد ألعاب مطابقة';

  @override
  String get noResultsHint => 'جرّب إزالة أحد الفلاتر أو البحث عن شيء آخر.';

  @override
  String get filters => 'الفلاتر';

  @override
  String get sortBy => 'الترتيب';

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get sortPriceAsc => 'السعر: من الأقل للأعلى';

  @override
  String get sortPriceDesc => 'السعر: من الأعلى للأقل';

  @override
  String get sortRating => 'الأعلى تقييمًا';

  @override
  String get priceRange => 'السعر (د.ك)';

  @override
  String get brandsFilter => 'الماركات';

  @override
  String get ageFilter => 'العمر';

  @override
  String get inStockOnly => 'المتوفر فقط';

  @override
  String get apply => 'تطبيق';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get addedToCart => 'تمت الإضافة إلى السلة';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get outOfStock => 'نفدت الكمية';

  @override
  String get description => 'الوصف';

  @override
  String get safetyNotes => 'ملاحظات السلامة';

  @override
  String get shippingReturns => 'الشحن والإرجاع';

  @override
  String get shippingReturnsBody =>
      'توصيل مجاني للطلبات فوق 15.000 د.ك — وإلا 2.000 د.ك لجميع مناطق الكويت. التوصيل خلال 1–3 أيام عمل. يمكن إرجاع الألعاب غير المفتوحة خلال 14 يومًا.';

  @override
  String get moreForAge => 'المزيد لهذا العمر';

  @override
  String get share => 'مشاركة';

  @override
  String get linkCopied => 'تم نسخ الرابط';

  @override
  String get chooseOption => 'اختر خيارًا';

  @override
  String get quantity => 'الكمية';

  @override
  String get saleBadge => 'تخفيض';

  @override
  String get newBadge => 'جديد';

  @override
  String ratingCount(int count) {
    return '($count)';
  }

  @override
  String get cartTitle => 'سلتك';

  @override
  String get cartEmpty => 'سلتك فارغة';

  @override
  String get cartEmptyHint => 'صندوق الألعاب بانتظارك — ابحث عن شيء يحبونه.';

  @override
  String get startShopping => 'ابدأ التسوق';

  @override
  String get promoCode => 'رمز الخصم';

  @override
  String get promoApply => 'تطبيق';

  @override
  String get promoInvalid => 'هذا الرمز غير صالح';

  @override
  String promoApplied(String code) {
    return 'تم تطبيق $code';
  }

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get shipping => 'الشحن';

  @override
  String get freeShipping => 'مجاني';

  @override
  String get discount => 'الخصم';

  @override
  String get total => 'الإجمالي';

  @override
  String get goToCheckout => 'إتمام الشراء';

  @override
  String itemRemoved(String name) {
    return 'تمت إزالة $name';
  }

  @override
  String get undo => 'تراجع';

  @override
  String get trustRow => 'كي نت · الدفع عند الاستلام · دفع آمن';

  @override
  String get checkoutTitle => 'إتمام الشراء';

  @override
  String get stepContact => 'التواصل';

  @override
  String get stepAddress => 'العنوان';

  @override
  String get stepPayment => 'الدفع';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'الهاتف (+965)';

  @override
  String get governorate => 'المحافظة';

  @override
  String get area => 'المنطقة';

  @override
  String get block => 'القطعة';

  @override
  String get street => 'الشارع';

  @override
  String get building => 'المبنى';

  @override
  String get floorField => 'الطابق';

  @override
  String get apartment => 'الشقة';

  @override
  String get directions => 'إرشادات للسائق';

  @override
  String get optional => 'اختياري';

  @override
  String get continueBtn => 'متابعة';

  @override
  String get backBtn => 'رجوع';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get payKnet => 'كي نت';

  @override
  String get payKnetDesc => 'ادفع ببطاقة بنكك الكويتي';

  @override
  String get payCard => 'بطاقة ائتمان';

  @override
  String get payCardDesc => 'فيزا أو ماستركارد';

  @override
  String get payCod => 'الدفع عند الاستلام';

  @override
  String get payCodDesc => 'ادفع للسائق عند وصول طلبك';

  @override
  String get payApplePay => 'أبل باي';

  @override
  String get phase2Tag => 'قريبًا';

  @override
  String get placeOrder => 'تأكيد الطلب';

  @override
  String payNow(String amount) {
    return 'ادفع $amount';
  }

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get invalidEmail => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get invalidPhone => 'أدخل رقمًا كويتيًا من 8 أرقام';

  @override
  String get gatewayTitle => 'كي نت — بيئة تجريبية';

  @override
  String get gatewaySandboxNote =>
      'هذه صفحة الدفع التجريبية. لا يتم خصم أي مبلغ حقيقي؛ في الإنتاج ستكون صفحة كي نت من ماي فاتورة.';

  @override
  String get gatewayPaySuccess => 'محاكاة دفع ناجح';

  @override
  String get gatewayPayFail => 'محاكاة دفع فاشل';

  @override
  String get gatewayAmount => 'المبلغ';

  @override
  String get paymentSuccessTitle => 'تم تأكيد الطلب!';

  @override
  String get paymentSuccessBody =>
      'شكرًا لك — تم الدفع بنجاح وجاري تجهيز الألعاب.';

  @override
  String get codSuccessTitle => 'تم تأكيد الطلب!';

  @override
  String codSuccessBody(String amount) {
    return 'جهّز $amount نقدًا — سيحصّلها السائق عند التوصيل.';
  }

  @override
  String get paymentFailedTitle => 'لم تتم عملية الدفع';

  @override
  String get paymentFailedBody =>
      'لم يُخصم أي مبلغ. يمكنك المحاولة مرة أخرى أو التحويل إلى الدفع عند الاستلام.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get orderNumber => 'رقم الطلب';

  @override
  String get trackOrder => 'تتبع الطلب';

  @override
  String get continueShopping => 'مواصلة التسوق';

  @override
  String get createAccountPrompt => 'أنشئ حسابًا لتتبع هذا الطلب من أي جهاز.';

  @override
  String get createAccountCta => 'إنشاء حساب';

  @override
  String get ordersTitle => 'طلباتي';

  @override
  String get ordersEmpty => 'لا توجد طلبات بعد';

  @override
  String get ordersEmptyHint => 'الطلبات التي تضعها من هذا الجهاز ستظهر هنا.';

  @override
  String get orderLookupTitle => 'البحث عن طلب';

  @override
  String get orderLookupHint =>
      'أدخل رقم الطلب من رسالة التأكيد ورقم الهاتف المستخدم عند الشراء.';

  @override
  String get find => 'بحث';

  @override
  String get orderNotFound => 'لا يوجد طلب مطابق لهذا الرقم والهاتف.';

  @override
  String placedOn(String date) {
    return 'تم الطلب في $date';
  }

  @override
  String get deliverTo => 'التوصيل إلى';

  @override
  String get paymentLabel => 'الدفع';

  @override
  String get statusPendingPayment => 'بانتظار الدفع';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get statusCodConfirmed => 'مؤكد — الدفع عند الاستلام';

  @override
  String get statusProcessing => 'جاري التجهيز';

  @override
  String get statusShipped => 'في الطريق';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusRefunded => 'مسترد';

  @override
  String get accountTitle => 'حسابي';

  @override
  String get guestTitle => 'أنت تتصفح كضيف';

  @override
  String get guestHint => 'سجّل الدخول لمزامنة سلتك ومفضلتك عبر الأجهزة.';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signInTitle => 'أهلًا بك في لوت';

  @override
  String get signInSubtitle =>
      'سجّل الدخول لمزامنة ألعابك — أو واصل التصفح كضيف.';

  @override
  String get signInEmail => 'المتابعة بالبريد الإلكتروني';

  @override
  String get signInGoogle => 'المتابعة عبر جوجل';

  @override
  String get signInApple => 'المتابعة عبر آبل';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get demoModeNote =>
      'يُفعَّل تسجيل الدخول عند ربط خادم المتجر. كل شيء آخر يعمل — التصفح والسلة والدفع في الوضع التجريبي.';

  @override
  String get language => 'اللغة';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get lookupOrder => 'البحث عن طلب بالرقم';

  @override
  String get aboutDemo => 'عن هذا العرض التجريبي';

  @override
  String get aboutDemoBody =>
      'هذا هو العرض التجريبي لمتجر لوت. الكتالوج والسلة والدفع تعمل محليًا في وضع تجريبي — دون مدفوعات حقيقية أو حاجة لحساب.';

  @override
  String get wishlistTitle => 'المفضلة';

  @override
  String get wishlistEmpty => 'لا يوجد شيء محفوظ بعد';

  @override
  String get wishlistEmptyHint => 'اضغط على القلب على أي لعبة لحفظها هنا.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';
}
