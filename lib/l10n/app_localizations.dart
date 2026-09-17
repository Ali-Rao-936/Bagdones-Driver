import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zaytoon Driver'**
  String get appTitle;

  /// No description provided for @splashNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get splashNoInternet;

  /// No description provided for @splashRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get splashRetry;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+9627xxxxxxxx'**
  String get loginPhoneHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @loginPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get loginPhoneRequired;

  /// No description provided for @loginPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get loginPhoneInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginPasswordTooShort;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed — check your phone and password'**
  String get loginFailed;

  /// No description provided for @loginUnexpectedResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response from server. Please try again.'**
  String get loginUnexpectedResponse;

  /// No description provided for @tabLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get tabLive;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @liveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live orders'**
  String get liveTitle;

  /// No description provided for @liveEmpty.
  ///
  /// In en, this message translates to:
  /// **'No live orders right now'**
  String get liveEmpty;

  /// No description provided for @liveError.
  ///
  /// In en, this message translates to:
  /// **'Could not load live orders — pull to retry'**
  String get liveError;

  /// No description provided for @liveNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get liveNewBadge;

  /// No description provided for @liveView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get liveView;

  /// No description provided for @liveMarkDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark delivered'**
  String get liveMarkDelivered;

  /// No description provided for @liveMarkDeliveredFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not mark as delivered'**
  String get liveMarkDeliveredFailed;

  /// No description provided for @liveAssignedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Assigned just now'**
  String get liveAssignedJustNow;

  /// No description provided for @liveAssignedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Assigned {minutes} min ago'**
  String liveAssignedMinutesAgo(int minutes);

  /// No description provided for @liveAssignedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Assigned {hours} hr ago'**
  String liveAssignedHoursAgo(int hours);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No deliveries yet'**
  String get historyEmpty;

  /// No description provided for @historyError.
  ///
  /// In en, this message translates to:
  /// **'Could not load history — pull to retry'**
  String get historyError;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailsTitle;

  /// No description provided for @orderDetailsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load order details'**
  String get orderDetailsLoadError;

  /// No description provided for @orderDetailsPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get orderDetailsPickup;

  /// No description provided for @orderDetailsDeliveryTo.
  ///
  /// In en, this message translates to:
  /// **'Delivery to'**
  String get orderDetailsDeliveryTo;

  /// No description provided for @orderDetailsDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get orderDetailsDriver;

  /// No description provided for @orderDetailsItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orderDetailsItems;

  /// No description provided for @orderDetailsNoItems.
  ///
  /// In en, this message translates to:
  /// **'No item details available'**
  String get orderDetailsNoItems;

  /// No description provided for @orderDetailsNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get orderDetailsNote;

  /// No description provided for @orderDetailsDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get orderDetailsDeliveryFee;

  /// No description provided for @orderDetailsTotalToCollect.
  ///
  /// In en, this message translates to:
  /// **'Total to collect'**
  String get orderDetailsTotalToCollect;

  /// No description provided for @orderDetailsCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get orderDetailsCall;

  /// No description provided for @orderDetailsNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get orderDetailsNavigate;

  /// No description provided for @orderDetailsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderDetailsDelivered;

  /// No description provided for @orderDetailsDeliveredAt.
  ///
  /// In en, this message translates to:
  /// **'Delivered {time}'**
  String orderDetailsDeliveredAt(String time);

  /// No description provided for @orderDetailsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get orderDetailsCustomer;

  /// No description provided for @orderDetailsNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location available for this order'**
  String get orderDetailsNoLocation;

  /// No description provided for @orderDetailsMapsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open Maps'**
  String get orderDetailsMapsFailed;

  /// No description provided for @orderDetailsDialerFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the dialer'**
  String get orderDetailsDialerFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelp;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get settingsAbout;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get settingsLogoutConfirmTitle;

  /// No description provided for @settingsLogoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to log in again to see your orders.'**
  String get settingsLogoutConfirmBody;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNone.
  ///
  /// In en, this message translates to:
  /// **'No profile data available'**
  String get profileNone;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileStatus.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get profileStatus;

  /// No description provided for @profileActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profileActive;

  /// No description provided for @profileInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get profileInactive;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @helpGettingOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting an order'**
  String get helpGettingOrderTitle;

  /// No description provided for @helpGettingOrderBody.
  ///
  /// In en, this message translates to:
  /// **'Orders are assigned to you by the dispatch team. You\'ll see them appear on the Live tab.'**
  String get helpGettingOrderBody;

  /// No description provided for @helpMarkDeliveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Marking an order delivered'**
  String get helpMarkDeliveredTitle;

  /// No description provided for @helpMarkDeliveredBody.
  ///
  /// In en, this message translates to:
  /// **'Open the order from the Live tab and tap Mark delivered once you have handed it to the customer.'**
  String get helpMarkDeliveredBody;

  /// No description provided for @helpMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Need more help?'**
  String get helpMoreTitle;

  /// No description provided for @helpMoreBody.
  ///
  /// In en, this message translates to:
  /// **'Contact your dispatcher directly for now.'**
  String get helpMoreBody;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Placeholder privacy policy text — replace with the real policy before release.'**
  String get aboutPrivacyBody;

  /// No description provided for @aboutTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get aboutTermsTitle;

  /// No description provided for @aboutTermsBody.
  ///
  /// In en, this message translates to:
  /// **'Placeholder terms text — replace with the real terms before release.'**
  String get aboutTermsBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
