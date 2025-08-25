import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserSession extends ChangeNotifier {
  UserSession({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance {
    _authSub = _auth.authStateChanges().listen(_onAuth);
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  bool? needsOnboarding;

  void _onAuth(User? user) {
    _userDocSub?.cancel();
    if (user == null) {
      needsOnboarding = null;
      notifyListeners();
      return;
    }
    final ref = _firestore.collection('users').doc(user.uid);
    _userDocSub = ref.snapshots().listen((snap) {
      final data = snap.data();
      needsOnboarding = (data?['needsOnboarding'] == true);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}
