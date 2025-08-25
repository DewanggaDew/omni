import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoriesRepository {
  CategoriesRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _catCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('categories');

  Stream<List<Map<String, dynamic>>> watchAll() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _catCol(uid)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
