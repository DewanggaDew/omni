import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goals_repository.dart';
import '../models/goal_model.dart';

class FirestoreGoalsRepository implements GoalsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreGoalsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<List<Goal>> getGoals(String userId) {
    debugPrint('FirestoreGoalsRepository: Getting goals for user $userId');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint(
            'FirestoreGoalsRepository: Received ${snapshot.docs.length} goals',
          );
          return snapshot.docs
              .map((doc) => GoalModel.fromDoc(doc).toEntity())
              .toList();
        });
  }

  @override
  Future<void> createGoal(Goal goal) async {
    final goalModel = GoalModel.fromEntity(goal);
    await _firestore
        .collection('users')
        .doc(goal.userId)
        .collection('goals')
        .doc(goal.id)
        .set(goalModel.toMap());
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    final goalModel = GoalModel.fromEntity(goal);
    await _firestore
        .collection('users')
        .doc(goal.userId)
        .collection('goals')
        .doc(goal.id)
        .update(goalModel.toMap());
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    // Note: This requires knowing the userId. In a real implementation,
    // you might want to pass userId as a parameter or get it from auth.
    final userId = _getCurrentUserId();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  @override
  Future<Goal?> getGoal(String goalId) async {
    final userId = _getCurrentUserId();
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .get();

    if (!doc.exists) return null;
    return GoalModel.fromDoc(doc).toEntity();
  }

  @override
  Future<void> updateGoalProgress(String goalId, double progress) async {
    final userId = _getCurrentUserId();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .update({'currentProgress': progress});
  }

  @override
  Future<double> calculateGoalProgress(
    String goalId,
    List<String> linkedCategories,
  ) async {
    if (linkedCategories.isEmpty) return 0;

    final userId = _getCurrentUserId();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Calculate income minus expenses for linked categories this month
    final transactionsQuery = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('categoryId', whereIn: linkedCategories)
        .get();

    double totalAmount = 0;
    for (final doc in transactionsQuery.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num).toDouble();
      final type = data['type'] as String;

      if (type == 'income') {
        totalAmount += amount;
      } else {
        totalAmount -= amount; // Subtract expenses
      }
    }

    // For savings goals, we want the net positive amount (income - expenses)
    return totalAmount > 0 ? totalAmount : 0;
  }

  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }
}
