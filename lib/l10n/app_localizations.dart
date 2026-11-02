import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @apodToday.
  ///
  /// In en, this message translates to:
  /// **'Image of the Day'**
  String get apodToday;

  /// No description provided for @otherApods.
  ///
  /// In en, this message translates to:
  /// **'Other Images'**
  String get otherApods;

  /// No description provided for @downloadApod.
  ///
  /// In en, this message translates to:
  /// **'Download Image'**
  String get downloadApod;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @pleaseLoginToSeeFavorites.
  ///
  /// In en, this message translates to:
  /// **'Please log in to see your favorites'**
  String get pleaseLoginToSeeFavorites;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @appeareance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appeareance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoritesLocalHint.
  ///
  /// In en, this message translates to:
  /// **'Favorites are saved on this device. Log in to sync them across devices.'**
  String get favoritesLocalHint;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet. Tap the heart on any image to save it.'**
  String get noFavoritesYet;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @diariesNotification.
  ///
  /// In en, this message translates to:
  /// **'Daily Notification'**
  String get diariesNotification;

  /// No description provided for @qualityDownload.
  ///
  /// In en, this message translates to:
  /// **'Download Quality'**
  String get qualityDownload;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @notHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get notHaveAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @yetHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get yetHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @extras.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get extras;

  /// No description provided for @pleaseInterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseInterEmail;

  /// No description provided for @pleaseInterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseInterPassword;

  /// No description provided for @pleaseInterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseInterValidEmail;

  /// No description provided for @digitsPass.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get digitsPass;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email is already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @getApp.
  ///
  /// In en, this message translates to:
  /// **'Get the app'**
  String get getApp;

  /// No description provided for @getAppTitle.
  ///
  /// In en, this message translates to:
  /// **'We recommend the app'**
  String get getAppTitle;

  /// No description provided for @getAppIntro.
  ///
  /// In en, this message translates to:
  /// **'This website was originally built as an app. We recommend installing the app for the full experience.'**
  String get getAppIntro;

  /// No description provided for @getAppNotInPlay.
  ///
  /// In en, this message translates to:
  /// **'Available directly as APK — no Play Store needed. Install it and enjoy the full experience.'**
  String get getAppNotInPlay;

  /// No description provided for @getAppAndroidOnly.
  ///
  /// In en, this message translates to:
  /// **'Android only'**
  String get getAppAndroidOnly;

  /// No description provided for @getAppAction.
  ///
  /// In en, this message translates to:
  /// **'Download APK'**
  String get getAppAction;

  /// No description provided for @nasaDownTitle.
  ///
  /// In en, this message translates to:
  /// **'NASA service issues'**
  String get nasaDownTitle;

  /// No description provided for @nasaDownBody.
  ///
  /// In en, this message translates to:
  /// **'We can\'t load content because NASA services are failing (error {code}). This is outside our control. Please try again later.'**
  String nasaDownBody(Object code);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load data.'**
  String get genericError;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @translating.
  ///
  /// In en, this message translates to:
  /// **'Translating…'**
  String get translating;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get chooseDate;

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to today\'s picture'**
  String get backToToday;

  /// No description provided for @previousDays.
  ///
  /// In en, this message translates to:
  /// **'Previous days'**
  String get previousDays;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Open this picture'**
  String get readMore;

  /// No description provided for @viewFullScreen.
  ///
  /// In en, this message translates to:
  /// **'View full screen'**
  String get viewFullScreen;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @openVideo.
  ///
  /// In en, this message translates to:
  /// **'Open video'**
  String get openVideo;

  /// No description provided for @imageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this image.'**
  String get imageLoadError;

  /// No description provided for @imageCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get imageCredit;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Appod shows NASA\'s Astronomy Picture of the Day. Pictures and text belong to NASA and their credited authors. Appod is not affiliated with or endorsed by NASA.'**
  String get aboutBody;

  /// No description provided for @unofficialNotice.
  ///
  /// In en, this message translates to:
  /// **'Unofficial app · Not affiliated with NASA'**
  String get unofficialNotice;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code on GitHub'**
  String get sourceCode;

  /// No description provided for @loginToSync.
  ///
  /// In en, this message translates to:
  /// **'Log in to keep your favorites across devices.'**
  String get loginToSync;

  /// No description provided for @favoritesError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your favorites.'**
  String get favoritesError;

  /// No description provided for @favoriteAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoriteRemoved;

  /// No description provided for @errorBadDate.
  ///
  /// In en, this message translates to:
  /// **'There is no picture for this date. Try another day.'**
  String get errorBadDate;

  /// No description provided for @errorKey.
  ///
  /// In en, this message translates to:
  /// **'The NASA key is invalid or has expired.'**
  String get errorKey;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'There is no content for this date. Try another day.'**
  String get errorNotFound;

  /// No description provided for @errorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests to NASA. Wait a moment and try again.'**
  String get errorRateLimit;

  /// No description provided for @errorNasa.
  ///
  /// In en, this message translates to:
  /// **'NASA\'s service is having problems. Try again later.'**
  String get errorNasa;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'NASA took too long to respond. Try again.'**
  String get errorTimeout;

  /// No description provided for @errorConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get errorConnection;

  /// No description provided for @shareCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied. Paste it anywhere.'**
  String get shareCopied;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share this picture.'**
  String get shareFailed;

  /// No description provided for @downloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Download started.'**
  String get downloadStarted;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download this image.'**
  String get downloadFailed;

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved to your gallery.'**
  String get imageSaved;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow access to your gallery to save images.'**
  String get permissionDenied;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Look at the astronomy picture of {date}: {url}'**
  String shareText(String date, String url);

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'This page doesn\'t exist'**
  String get pageNotFound;

  /// No description provided for @pageNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The address is wrong, or there is no picture for that date.'**
  String get pageNotFoundBody;

  /// No description provided for @onThisDay.
  ///
  /// In en, this message translates to:
  /// **'On this day'**
  String get onThisDay;

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String yearsAgo(int count);

  /// No description provided for @fromTheArchive.
  ///
  /// In en, this message translates to:
  /// **'From the archive'**
  String get fromTheArchive;

  /// No description provided for @showingSaved.
  ///
  /// In en, this message translates to:
  /// **'No connection. Showing what is saved.'**
  String get showingSaved;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
