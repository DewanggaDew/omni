import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:omni/firebase_options.dart';
import 'main.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

const bool kFirebaseEnabled = bool.fromEnvironment(
  'FIREBASE',
  defaultValue: false,
);

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kFirebaseEnabled) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Log app_open
      try {
        await FirebaseAnalytics.instance.logAppOpen();
      } catch (_) {}
      // Enable App Check (Debug provider for dev build)
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
        appleProvider: kDebugMode
            ? AppleProvider.debug
            : AppleProvider.appAttest,
      );
    } catch (e) {
      if (kDebugMode) {
        // Allow running without Firebase configured in dev.
        debugPrint('Firebase init skipped: $e');
      }
    }
  }

  runApp(const OmniApp());
}
