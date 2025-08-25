import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _ensureUserDocument(cred.user);
    await _identifyCrashlyticsUser();
    return cred;
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _ensureUserDocument(cred.user);
    await _identifyCrashlyticsUser();
    return cred;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> _ensureUserDocument(User? user) async {
    if (user == null) return;
    final ref = _firestore.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'currency': null, // set in onboarding later
        'country': null,
        'settings': {},
        'createdAt': FieldValue.serverTimestamp(),
        'appVersion': null,
      });
      await _seedDefaultCategories(user.uid);
      // Optional: could navigate onboarding via UI state. For now, we leave a flag.
      await ref.update({'needsOnboarding': true});
    }
  }

  Future<void> _seedDefaultCategories(String uid) async {
    final batch = _firestore.batch();
    final cats = <Map<String, dynamic>>[
      {'name': 'Food', 'emoji': '🍽️', 'color': 0xFFE57373, 'type': 'expense'},
      {
        'name': 'Transport',
        'emoji': '🚌',
        'color': 0xFF64B5F6,
        'type': 'expense',
      },
      {
        'name': 'Shopping',
        'emoji': '🛍️',
        'color': 0xFFBA68C8,
        'type': 'expense',
      },
      {'name': 'Bills', 'emoji': '💡', 'color': 0xFFFFB74D, 'type': 'expense'},
      {'name': 'Health', 'emoji': '⚕️', 'color': 0xFF81C784, 'type': 'expense'},
      {'name': 'Salary', 'emoji': '💼', 'color': 0xFF4DB6AC, 'type': 'income'},
      {'name': 'Other', 'emoji': '📦', 'color': 0xFF90A4AE, 'type': 'expense'},
    ];
    for (final c in cats) {
      final doc = _firestore
          .collection('users')
          .doc(uid)
          .collection('categories')
          .doc();
      batch.set(doc, c);
    }
    await batch.commit();
  }

  Future<void> _identifyCrashlyticsUser() async {
    final u = _auth.currentUser;
    if (u == null) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(u.uid);
    await FirebaseCrashlytics.instance.setCustomKey('email', u.email ?? '');
  }
}
