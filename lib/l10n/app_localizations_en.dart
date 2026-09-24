// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zaytoon Driver';

  @override
  String get splashNoInternet => 'No internet connection';

  @override
  String get splashRetry => 'Try again';

  @override
  String get loginPhoneLabel => 'Phone number';

  @override
  String get loginPhoneHint => '+9627xxxxxxxx';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginPhoneRequired => 'Phone number is required';

  @override
  String get loginPhoneInvalid => 'Enter a valid phone number';

  @override
  String get loginPasswordRequired => 'Password is required';

  @override
  String get loginPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get loginFailed => 'Login failed — check your phone and password';

  @override
  String get loginUnexpectedResponse =>
      'Unexpected response from server. Please try again.';

  @override
  String get tabLive => 'Live';

  @override
  String get tabHistory => 'History';

  @override
  String get tabSettings => 'Settings';

  @override
  String get liveTitle => 'Live orders';

  @override
  String get liveEmpty => 'No live orders right now';

  @override
  String get liveError => 'Could not load live orders — pull to retry';

  @override
  String get liveNewBadge => 'New';

  @override
  String get liveView => 'View';

  @override
  String get liveStartDelivery => 'Start delivery';

  @override
  String get liveStartDeliveryFailed => 'Could not start delivery';

  @override
  String get liveMarkDelivered => 'Mark delivered';

  @override
  String get liveMarkDeliveredFailed => 'Could not mark as delivered';

  @override
  String get liveAssignedJustNow => 'Assigned just now';

  @override
  String liveAssignedMinutesAgo(int minutes) {
    return 'Assigned $minutes min ago';
  }

  @override
  String liveAssignedHoursAgo(int hours) {
    return 'Assigned $hours hr ago';
  }

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No deliveries yet';

  @override
  String get historyError => 'Could not load history — pull to retry';

  @override
  String get orderDetailsTitle => 'Order Details';

  @override
  String get orderDetailsLoadError => 'Could not load order details';

  @override
  String get orderDetailsPickup => 'Pickup';

  @override
  String get orderDetailsDeliveryTo => 'Delivery to';

  @override
  String get orderDetailsDriver => 'Driver';

  @override
  String get orderDetailsItems => 'Items';

  @override
  String get orderDetailsNoItems => 'No item details available';

  @override
  String get orderDetailsNote => 'Note';

  @override
  String get orderDetailsDeliveryFee => 'Delivery fee';

  @override
  String get orderDetailsTotalToCollect => 'Total to collect';

  @override
  String get orderDetailsCall => 'Call';

  @override
  String get orderDetailsNavigate => 'Navigate';

  @override
  String get orderDetailsDelivered => 'Delivered';

  @override
  String orderDetailsDeliveredAt(String time) {
    return 'Delivered $time';
  }

  @override
  String get orderDetailsCustomer => 'Customer';

  @override
  String get orderDetailsNoLocation => 'No location available for this order';

  @override
  String get orderDetailsMapsFailed => 'Could not open Maps';

  @override
  String get orderDetailsDialerFailed => 'Could not open the dialer';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsAbout => 'About app';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutConfirmTitle => 'Log out?';

  @override
  String get settingsLogoutConfirmBody =>
      'You\'ll need to log in again to see your orders.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNone => 'No profile data available';

  @override
  String get profileName => 'Name';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileStatus => 'Account status';

  @override
  String get profileActive => 'Active';

  @override
  String get profileInactive => 'Inactive';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpGettingOrderTitle => 'Getting an order';

  @override
  String get helpGettingOrderBody =>
      'Orders are assigned to you by the dispatch team. You\'ll see them appear on the Live tab.';

  @override
  String get helpMarkDeliveredTitle => 'Marking an order delivered';

  @override
  String get helpMarkDeliveredBody =>
      'Open the order from the Live tab and tap Mark delivered once you have handed it to the customer.';

  @override
  String get helpMoreTitle => 'Need more help?';

  @override
  String get helpMoreBody => 'Contact your dispatcher directly for now.';

  @override
  String get aboutTitle => 'About app';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacyTitle => 'Privacy policy';

  @override
  String get aboutPrivacyBody =>
      'Placeholder privacy policy text — replace with the real policy before release.';

  @override
  String get aboutTermsTitle => 'Terms of service';

  @override
  String get aboutTermsBody =>
      'Placeholder terms text — replace with the real terms before release.';
}
