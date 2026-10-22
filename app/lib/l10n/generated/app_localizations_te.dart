// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'కార్యలోక్';

  @override
  String get dashboardTitle => 'పౌర సమస్యల ఫిర్యాదు వ్యవస్థ';

  @override
  String get welcomeBack => 'స్వాగతం';

  @override
  String get reportNewIssue => 'కొత్త సమస్యను నమోదు చేయండి';

  @override
  String get myReports => 'నా ఫిర్యాదులు';

  @override
  String get profile => 'ప్రొఫైల్';

  @override
  String get settings => 'సెట్టింగ్లు';

  @override
  String get logout => 'లాగ్ అవుట్';

  @override
  String get helpSupport => 'సహాయం & మద్దతు';

  @override
  String get language => 'భాశ';

  @override
  String get login => 'లాగిన్';

  @override
  String get signup => 'నమోదు';

  @override
  String get email => 'ఇమెయిల్';

  @override
  String get password => 'పాస్వర్డ్';

  @override
  String get loginSubtitle => 'సమస్యలను నివేదించడానికి లాగిన్ చేయండి';

  @override
  String get signupSubtitle => 'మార్పు కోసం మాతో చేరండి';

  @override
  String get dontHaveAccount => 'ఖాతా లేదా? ';

  @override
  String get alreadyHaveAccount => 'ఇప్పటికే ఖాతా ఉందా? ';

  @override
  String get submit => 'సమర్పించు';

  @override
  String get dashboard => 'డ్యాష్‌బోర్డ్';

  @override
  String get close => 'మూసివేయండి';

  @override
  String get cancel => 'రద్దు చేయండి';

  @override
  String get notificationsEmpty => 'కొత్త నోటిఫికేషన్‌లు లేవు';

  @override
  String get helpTitle => 'సమస్యను ఎలా నివేదించాలి:';

  @override
  String get helpSteps =>
      '1. సమస్య వర్గాన్ని ఎంచుకోండి\n2. స్థాన వివరాలను జోడించండి\n3. వివరణ రాయండి\n4. ఫోటోలు/వీడియోలను జోడించండి\n5. నివేదికను సమర్పించండి';

  @override
  String get supportContact =>
      'సాంకేతిక మద్దతు కోసం, సంప్రదించండి: support@civicreporter.com';

  @override
  String get settingsFuture =>
      'సెట్టింగ్‌ల ప్యానెల్ భవిష్యత్తు నవీకరణలలో అందుబాటులో ఉంటుంది.';

  @override
  String get logoutConfirm => 'మీరు ఖచ్చితంగా లాగౌట్ చేయాలనుకుంటున్నారా?';

  @override
  String get reportTitle => 'మీ సమస్యను నివేదించండి';

  @override
  String get locationLabel => 'స్థానం';

  @override
  String get locationHint => 'స్థానాన్ని నమోదు చేయండి...';

  @override
  String get getLocationTooltip => 'ప్రస్తుత స్థానాన్ని పొందండి';

  @override
  String get descriptionLabel => 'వివరణ';

  @override
  String get descriptionHint => 'సమస్యను వివరంగా వివరించండి...';

  @override
  String get addPhotosLabel => 'ఫోటోలను జోడించండి';

  @override
  String get uploadPhotos => 'ఫోటోలను అప్‌లోడ్ చేయండి';

  @override
  String get photoSpecs => 'JPG, PNG 10MB వరకు';

  @override
  String get voiceRecording => 'వాయిస్ రికార్డింగ్';

  @override
  String get videoAttachment => 'వీడియో అటాచ్‌మెంట్';

  @override
  String get takePhoto => 'ఫోటో తీయండి';

  @override
  String get uploadVideo => 'వీడియో అప్‌లోడ్';

  @override
  String get recordVoice => 'వాయిస్ రికార్డ్';

  @override
  String get submitReport => 'నివేదికను సమర్పించు';

  @override
  String get submittingReport => 'నివేదికను సమర్పిస్తోంది...';

  @override
  String get reportSuccessTitle => 'విజయం!';

  @override
  String get reportSuccessMessage =>
      'మీ నివేదిక విజయవంతంగా సమర్పించబడింది! మీరు రిపోర్ట్స్ విభాగంలో దీని పురోగతిని ట్రాక్ చేయవచ్చు.';

  @override
  String get viewReports => 'నివేదికలను వీక్షించండి';

  @override
  String get locationError =>
      'ప్రస్తుత స్థానాన్ని పొందలేకపోయాము. దయచేసి మాన్యువల్‌గా నమోదు చేయండి.';

  @override
  String get locationSuccess => 'స్థానం విజయవంతంగా పొందబడింది!';

  @override
  String get photoSuccess => 'ఫోటో విజయవంతంగా జోడించబడింది!';

  @override
  String errorGeneric(Object error) {
    return 'లోపం: $error';
  }

  @override
  String get voiceRecordingAttached => 'వాయిస్ రికార్డింగ్ జోడించబడింది!';

  @override
  String get loading => 'లోడ్ అవుతోంది...';

  @override
  String duration(int minutes, String seconds) {
    return 'నిడివి: $minutes:$seconds';
  }

  @override
  String fileSize(String sizeInMB) {
    return 'పరిమాణం: $sizeInMB MB';
  }

  @override
  String get searchReports => 'నివేదికలను శోధించండి...';

  @override
  String get noReportsFound => 'మీ శోధనకు తగిన నివేదికలు కనుగొనబడలేదు.';
}
