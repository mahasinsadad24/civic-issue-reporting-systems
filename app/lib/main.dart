import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/location_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Handle error or ignore if optional
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("FIREBASE INIT FAILED: $e");
  }

  // Request location permission on app startup
  final locationService = LocationService();
  await locationService.requestLocationPermission();

  runApp(const CivicIssueReporterApp());
}
