// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Karyalok';

  @override
  String get dashboardTitle => 'CIVIC ISSUE REPORT SYSTEM';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get reportNewIssue => 'Report New Issue';

  @override
  String get myReports => 'My Reports';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get language => 'Language';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get loginSubtitle => 'Sign in to continue reporting issues';

  @override
  String get signupSubtitle => 'Join us to make a difference';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get submit => 'Submit';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get notificationsEmpty => 'No new notifications';

  @override
  String get helpTitle => 'How to report an issue:';

  @override
  String get helpSteps =>
      '1. Select issue category\n2. Add location details\n3. Write description\n4. Add photos/videos\n5. Submit report';

  @override
  String get supportContact =>
      'For technical support, contact: support@civicreporter.com';

  @override
  String get settingsFuture =>
      'Settings panel will be available in future updates.';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get reportTitle => 'REPORT YOUR ISSUE';

  @override
  String get locationLabel => 'Location';

  @override
  String get locationHint => 'Enter location...';

  @override
  String get getLocationTooltip => 'Get current location';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'Describe the issue in detail...';

  @override
  String get addPhotosLabel => 'Add Photos';

  @override
  String get uploadPhotos => 'Upload Photos';

  @override
  String get photoSpecs => 'JPG, PNG up to 10MB';

  @override
  String get voiceRecording => 'Voice Recording';

  @override
  String get videoAttachment => 'Video Attachment';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get uploadVideo => 'Upload Video';

  @override
  String get recordVoice => 'Record Voice';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get submittingReport => 'Submitting report...';

  @override
  String get reportSuccessTitle => 'Success!';

  @override
  String get reportSuccessMessage =>
      'Your report has been submitted successfully! You can track its progress in the Reports section.';

  @override
  String get viewReports => 'View Reports';

  @override
  String get locationError =>
      'Unable to get current location. Please enter manually.';

  @override
  String get locationSuccess => 'Location retrieved successfully!';

  @override
  String get photoSuccess => 'Photo added successfully!';

  @override
  String errorGeneric(Object error) {
    return 'Error: $error';
  }

  @override
  String get voiceRecordingAttached => 'Voice recording attached!';

  @override
  String get loading => 'Loading...';

  @override
  String duration(int minutes, String seconds) {
    return 'Duration: $minutes:$seconds';
  }

  @override
  String fileSize(String sizeInMB) {
    return 'Size: $sizeInMB MB';
  }

  @override
  String get searchReports => 'Search reports...';

  @override
  String get noReportsFound => 'No reports found matching your criteria.';
}
