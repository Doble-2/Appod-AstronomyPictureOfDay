// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get explore => 'Explore';

  @override
  String get apodToday => 'Image of the Day';

  @override
  String get otherApods => 'Other Images';

  @override
  String get downloadApod => 'Download Image';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get pleaseLoginToSeeFavorites => 'Please log in to see your favorites';

  @override
  String get soon => 'Soon';

  @override
  String get appeareance => 'Appearance';

  @override
  String get darkMode => 'Dark';

  @override
  String get lightMode => 'Light';

  @override
  String get systemMode => 'System';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get account => 'Account';

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesLocalHint =>
      'Favorites are saved on this device. Log in to sync them across devices.';

  @override
  String get noFavoritesYet =>
      'No favorites yet. Tap the heart on any image to save it.';

  @override
  String get settings => 'Settings';

  @override
  String get diariesNotification => 'Daily Notification';

  @override
  String get qualityDownload => 'Download Quality';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get notHaveAccount => 'Don\'t have an account? Register';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get register => 'Register';

  @override
  String get yetHaveAccount => 'Already have an account? Login';

  @override
  String get createAccount => 'Create Account';

  @override
  String get extras => 'Extras';

  @override
  String get pleaseInterEmail => 'Please enter your email';

  @override
  String get pleaseInterPassword => 'Please enter your password';

  @override
  String get pleaseInterValidEmail => 'Please enter a valid email';

  @override
  String get digitsPass => 'Password must be at least 6 characters';

  @override
  String get emailAlreadyInUse => 'Email is already in use';

  @override
  String get getApp => 'Get the app';

  @override
  String get getAppTitle => 'We recommend the app';

  @override
  String get getAppIntro =>
      'This website was originally built as an app. We recommend installing the app for the full experience.';

  @override
  String get getAppNotInPlay =>
      'Available directly as APK — no Play Store needed. Install it and enjoy the full experience.';

  @override
  String get getAppAndroidOnly => 'Android only';

  @override
  String get getAppAction => 'Download APK';

  @override
  String get nasaDownTitle => 'NASA service issues';

  @override
  String nasaDownBody(Object code) {
    return 'We can\'t load content because NASA services are failing (error $code). This is outside our control. Please try again later.';
  }

  @override
  String get retry => 'Retry';

  @override
  String get genericError => 'Couldn\'t load data.';

  @override
  String get translate => 'Translate';

  @override
  String get share => 'Share';

  @override
  String get translating => 'Translating…';

  @override
  String get today => 'Today';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get backToToday => 'Go to today\'s picture';

  @override
  String get previousDays => 'Previous days';

  @override
  String get readMore => 'Open this picture';

  @override
  String get viewFullScreen => 'View full screen';

  @override
  String get close => 'Close';

  @override
  String get openVideo => 'Open video';

  @override
  String get imageLoadError => 'Couldn\'t load this image.';

  @override
  String get imageCredit => 'Credit';

  @override
  String get about => 'About';

  @override
  String get aboutBody =>
      'Appod shows NASA\'s Astronomy Picture of the Day. Pictures and text belong to NASA and their credited authors.';

  @override
  String get sourceCode => 'Source code on GitHub';

  @override
  String get loginToSync => 'Log in to keep your favorites across devices.';

  @override
  String get favoritesError => 'Couldn\'t load your favorites.';

  @override
  String get favoriteAdded => 'Added to favorites';

  @override
  String get favoriteRemoved => 'Removed from favorites';

  @override
  String get errorBadDate =>
      'There is no picture for this date. Try another day.';

  @override
  String get errorKey => 'The NASA key is invalid or has expired.';

  @override
  String get errorNotFound =>
      'There is no content for this date. Try another day.';

  @override
  String get errorRateLimit =>
      'Too many requests to NASA. Wait a moment and try again.';

  @override
  String get errorNasa =>
      'NASA\'s service is having problems. Try again later.';

  @override
  String get errorTimeout => 'NASA took too long to respond. Try again.';

  @override
  String get errorConnection => 'Check your internet connection and try again.';

  @override
  String get shareCopied => 'Link copied. Paste it anywhere.';

  @override
  String get shareFailed => 'Couldn\'t share this picture.';

  @override
  String get downloadStarted => 'Download started.';

  @override
  String get downloadFailed => 'Couldn\'t download this image.';

  @override
  String get imageSaved => 'Image saved to your gallery.';

  @override
  String get permissionDenied => 'Allow access to your gallery to save images.';

  @override
  String shareText(String date, String url) {
    return 'Look at the astronomy picture of $date: $url';
  }

  @override
  String get showPassword => 'Show password';

  @override
  String get pageNotFound => 'This page doesn\'t exist';

  @override
  String get pageNotFoundBody =>
      'The address is wrong, or there is no picture for that date.';

  @override
  String get onThisDay => 'On this day';

  @override
  String yearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String minRead(int minutes) {
    return '$minutes min read';
  }

  @override
  String get photoType => 'Photo';

  @override
  String get videoType => 'Video';

  @override
  String get fromTheArchive => 'From the archive';

  @override
  String get thisWeek => 'This week';
}
