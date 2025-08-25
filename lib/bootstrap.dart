import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:omni/firebase_options.dart';
import 'main.dart';

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
    } catch (e) {
      if (kDebugMode) {
        // Allow running without Firebase configured in dev.
        debugPrint('Firebase init skipped: $e');
      }
    }
  }

  runApp(const OmniApp());
}
