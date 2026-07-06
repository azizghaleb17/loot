// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Loot';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navCart => 'Cart';

  @override
  String get navWishlist => 'Wishlist';

  @override
  String get navAccount => 'Account';

  @override
  String get heroTitle => 'Little hands, big adventures';

  @override
  String get heroSubtitle =>
      'Toys picked for every age, delivered across Kuwait.';

  @override
  String get searchHint => 'Search toys, brands…';

  @override
  String get shopByAge => 'Shop by age';

  @override
  String get shopByCategory => 'Shop by category';

  @override
  String get shopByBrand => 'Popular brands';

  @override
  String get newArrivals => 'New arrivals';

  @override
  String get bestSellers => 'Best sellers';

  @override
  String get seeAll => 'See all';

  @override
  String get promoBannerTitle => '10% off your first order';

  @override
  String get promoBannerSubtitle => 'Use code LOOT10 at checkout';

  @override
  String get promoBannerCta => 'Shop now';

  @override
  String greatForAges(String label) {
    return 'Great for ages $label';
  }

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count toys',
      one: '1 toy',
      zero: 'No toys',
    );
    return '$_temp0';
  }

  @override
  String get noResults => 'No toys match';

  @override
  String get noResultsHint =>
      'Try removing a filter or searching for something else.';

  @override
  String get filters => 'Filters';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPriceAsc => 'Price: low to high';

  @override
  String get sortPriceDesc => 'Price: high to low';

  @override
  String get sortRating => 'Top rated';

  @override
  String get priceRange => 'Price (KD)';

  @override
  String get brandsFilter => 'Brands';

  @override
  String get ageFilter => 'Age';

  @override
  String get inStockOnly => 'In stock only';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get viewCart => 'View cart';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get description => 'Description';

  @override
  String get safetyNotes => 'Safety notes';

  @override
  String get shippingReturns => 'Shipping & returns';

  @override
  String get shippingReturnsBody =>
      'Free delivery on orders over KD 15.000 — otherwise KD 2.000 flat across Kuwait. Delivery in 1–3 working days. Unopened toys can be returned within 14 days.';

  @override
  String get moreForAge => 'More for this age';

  @override
  String get share => 'Share';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get chooseOption => 'Choose an option';

  @override
  String get quantity => 'Quantity';

  @override
  String get saleBadge => 'SALE';

  @override
  String get newBadge => 'NEW';

  @override
  String ratingCount(int count) {
    return '($count)';
  }

  @override
  String get cartTitle => 'Your cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyHint =>
      'The toy box is waiting — find something they\'ll love.';

  @override
  String get startShopping => 'Start shopping';

  @override
  String get promoCode => 'Promo code';

  @override
  String get promoApply => 'Apply';

  @override
  String get promoInvalid => 'That code doesn\'t work';

  @override
  String promoApplied(String code) {
    return '$code applied';
  }

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shipping => 'Shipping';

  @override
  String get freeShipping => 'Free';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get goToCheckout => 'Checkout';

  @override
  String itemRemoved(String name) {
    return '$name removed';
  }

  @override
  String get undo => 'Undo';

  @override
  String get trustRow => 'KNET · Cash on delivery · Secure checkout';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get stepContact => 'Contact';

  @override
  String get stepAddress => 'Address';

  @override
  String get stepPayment => 'Payment';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone (+965)';

  @override
  String get governorate => 'Governorate';

  @override
  String get area => 'Area';

  @override
  String get block => 'Block';

  @override
  String get street => 'Street';

  @override
  String get building => 'Building';

  @override
  String get floorField => 'Floor';

  @override
  String get apartment => 'Apartment';

  @override
  String get directions => 'Directions for the driver';

  @override
  String get optional => 'Optional';

  @override
  String get continueBtn => 'Continue';

  @override
  String get backBtn => 'Back';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get payKnet => 'KNET';

  @override
  String get payKnetDesc => 'Pay with your Kuwaiti bank card';

  @override
  String get payCard => 'Credit card';

  @override
  String get payCardDesc => 'Visa or Mastercard';

  @override
  String get payCod => 'Cash on delivery';

  @override
  String get payCodDesc => 'Pay the driver when your order arrives';

  @override
  String get payApplePay => 'Apple Pay';

  @override
  String get phase2Tag => 'Coming soon';

  @override
  String get placeOrder => 'Place order';

  @override
  String payNow(String amount) {
    return 'Pay $amount';
  }

  @override
  String get orderSummary => 'Order summary';

  @override
  String get requiredField => 'Required';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get invalidPhone => 'Enter a valid 8-digit Kuwaiti number';

  @override
  String get gatewayTitle => 'KNET — sandbox';

  @override
  String get gatewaySandboxNote =>
      'This is the demo payment page. No real money moves; in production this is the MyFatoorah hosted KNET page.';

  @override
  String get gatewayPaySuccess => 'Simulate successful payment';

  @override
  String get gatewayPayFail => 'Simulate failed payment';

  @override
  String get gatewayAmount => 'Amount';

  @override
  String get paymentSuccessTitle => 'Order confirmed!';

  @override
  String get paymentSuccessBody =>
      'Thank you — your payment went through and the toys are being packed.';

  @override
  String get codSuccessTitle => 'Order confirmed!';

  @override
  String codSuccessBody(String amount) {
    return 'Keep $amount ready in cash — the driver will collect it on delivery.';
  }

  @override
  String get paymentFailedTitle => 'Payment didn\'t go through';

  @override
  String get paymentFailedBody =>
      'No money was taken. You can try again or switch to cash on delivery.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get orderNumber => 'Order number';

  @override
  String get trackOrder => 'Track order';

  @override
  String get continueShopping => 'Continue shopping';

  @override
  String get createAccountPrompt =>
      'Create an account to track this order anywhere.';

  @override
  String get createAccountCta => 'Create account';

  @override
  String get ordersTitle => 'My orders';

  @override
  String get ordersEmpty => 'No orders yet';

  @override
  String get ordersEmptyHint => 'Orders you place on this device show up here.';

  @override
  String get orderLookupTitle => 'Find an order';

  @override
  String get orderLookupHint =>
      'Enter the order number from your confirmation and the phone used at checkout.';

  @override
  String get find => 'Find';

  @override
  String get orderNotFound => 'No order matches that number and phone.';

  @override
  String placedOn(String date) {
    return 'Placed $date';
  }

  @override
  String get deliverTo => 'Deliver to';

  @override
  String get paymentLabel => 'Payment';

  @override
  String get statusPendingPayment => 'Awaiting payment';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusCodConfirmed => 'Confirmed — pay on delivery';

  @override
  String get statusProcessing => 'Being packed';

  @override
  String get statusShipped => 'On the way';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String get accountTitle => 'Account';

  @override
  String get guestTitle => 'You\'re browsing as a guest';

  @override
  String get guestHint =>
      'Sign in to sync your cart and wishlist across devices.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInTitle => 'Welcome to Loot';

  @override
  String get signInSubtitle =>
      'Sign in to keep your toys in sync — or keep browsing as a guest.';

  @override
  String get signInEmail => 'Continue with email';

  @override
  String get signInGoogle => 'Continue with Google';

  @override
  String get signInApple => 'Continue with Apple';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get demoModeNote =>
      'Sign-in activates once the store backend is connected. Everything else works — browse, cart, and checkout in sandbox mode.';

  @override
  String get language => 'Language';

  @override
  String get myOrders => 'My orders';

  @override
  String get lookupOrder => 'Find an order by number';

  @override
  String get aboutDemo => 'About this demo';

  @override
  String get aboutDemoBody =>
      'This is the Loot web demo. Catalog, cart, and checkout run locally in sandbox mode — no real payments, no account needed.';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistEmpty => 'Nothing saved yet';

  @override
  String get wishlistEmptyHint => 'Tap the heart on any toy to keep it here.';

  @override
  String get retry => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong. Give it another try.';
}
