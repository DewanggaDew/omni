// Placeholder to keep builds green until FlutterFire CLI generates this file.
// Run: flutterfire configure --project=<your-project> per environment.
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

// Re-exported type alias for compatibility with FlutterFire generated API shape

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'dummy',
          appId: 'dummy',
          messagingSenderId: 'dummy',
          projectId: 'dummy',
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: 'dummy',
          appId: 'dummy',
          messagingSenderId: 'dummy',
          projectId: 'dummy',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const FirebaseOptions(
          apiKey: 'dummy',
          appId: 'dummy',
          messagingSenderId: 'dummy',
          projectId: 'dummy',
        );
    }
  }
}
