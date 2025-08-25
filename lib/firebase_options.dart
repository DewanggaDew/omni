// Generated options selector. For now, we point to dev by default.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'firebase_options_dev.dart' as dev;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      dev.DefaultFirebaseOptions.currentPlatform;
}
