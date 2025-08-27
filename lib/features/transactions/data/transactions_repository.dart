import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionsRepository {
  TransactionsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _txCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('transactions');

  Stream<List<Map<String, dynamic>>> watchLatest({int limit = 20}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _txCol(uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> add({
    required int amountMinor,
    required String type, // 'expense' | 'income'
    required DateTime date,
    String? categoryId,
    String? note,
  }) async {
    final uid = _auth.currentUser!.uid;
    await _txCol(uid).add({
      'amount': amountMinor,
      'type': type,
      'date': Timestamp.fromDate(date),
      'categoryId': categoryId,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete({
    required String id,
    required Map<String, dynamic> backup,
  }) async {
    final uid = _auth.currentUser!.uid;
    final doc = _txCol(uid).doc(id);
    await doc.delete();
    // Return backup to caller for potential undo.
  }

  Query<Map<String, dynamic>> buildLatestQuery({int limit = 20}) {
    final uid = _auth.currentUser!.uid;
    return _txCol(uid).orderBy('date', descending: true).limit(limit);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final uid = _auth.currentUser!.uid;
    final snap = await _txCol(uid).doc(id).get();
    if (!snap.exists) return null;
    return {'id': snap.id, ...snap.data()!};
  }

  Future<void> update({
    required String id,
    required int amountMinor,
    required String type,
    required DateTime date,
    String? categoryId,
    String? note,
  }) async {
    final uid = _auth.currentUser!.uid;
    await _txCol(uid).doc(id).update({
      'amount': amountMinor,
      'type': type,
      'date': Timestamp.fromDate(date),
      'categoryId': categoryId,
      'note': note,
    });
  }

  Future<void> duplicate(String id) async {
    final data = await fetchById(id);
    if (data == null) return;
    data.remove('id');
    final uid = _auth.currentUser!.uid;
    await _txCol(uid).add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }
}
