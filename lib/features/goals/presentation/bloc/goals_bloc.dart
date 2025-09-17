import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/get_goals.dart';
import '../../domain/usecases/create_goal.dart';
import '../../domain/usecases/update_goal.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/update_goal_progress.dart';
import '../../domain/entities/goal.dart';
import 'goals_event.dart';
import 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final GetGoalsUseCase _getGoals;
  final CreateGoalUseCase _createGoal;
  final UpdateGoalUseCase _updateGoal;
  final DeleteGoalUseCase _deleteGoal;
  final UpdateGoalProgressUseCase _updateGoalProgress;
  final FirebaseAuth _auth;

  bool _streamInitialized = false;

  GoalsBloc({
    required GetGoalsUseCase getGoals,
    required CreateGoalUseCase createGoal,
    required UpdateGoalUseCase updateGoal,
    required DeleteGoalUseCase deleteGoal,
    required UpdateGoalProgressUseCase updateGoalProgress,
    FirebaseAuth? auth,
  }) : _getGoals = getGoals,
       _createGoal = createGoal,
       _updateGoal = updateGoal,
       _deleteGoal = deleteGoal,
       _updateGoalProgress = updateGoalProgress,
       _auth = auth ?? FirebaseAuth.instance,
       super(const GoalsInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<ReloadGoals>(_onReloadGoals);
    on<CreateGoal>(_onCreateGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
    on<RefreshGoalProgress>(_onRefreshGoalProgress);
  }

  Future<void> _onLoadGoals(LoadGoals event, Emitter<GoalsState> emit) async {
    if (_streamInitialized) {
      debugPrint('GoalsBloc: LoadGoals ignored (already initialized)');
      return;
    }

    debugPrint('GoalsBloc: Loading goals (initial)...');
    emit(const GoalsLoading());

    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('GoalsBloc: User not authenticated');
        emit(const GoalsError('User not authenticated'));
        return;
      }

      debugPrint('GoalsBloc: User authenticated: ${user.uid}');
      debugPrint('GoalsBloc: User email: ${user.email}');
      debugPrint('GoalsBloc: User email verified: ${user.emailVerified}');

      // Test Firestore connection directly with simpler query
      try {
        debugPrint('GoalsBloc: Testing basic Firestore connection...');

        // Test user document (user-specific, should be allowed by rules)
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        debugPrint(
          'GoalsBloc: User doc exists: ${userDoc.exists}, data: ${userDoc.data()}',
        );

        // Test goals collection query
        final goalsQuery = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('goals')
            .get();
        debugPrint(
          'GoalsBloc: Goals query success - ${goalsQuery.docs.length} goals found',
        );

        // If we get here, Firestore is working, so load via stream
        debugPrint('GoalsBloc: Subscribing to goals stream via emit.forEach');
        _streamInitialized = true;
        await emit.forEach<List<Goal>>(
          _getGoals(user.uid),
          onData: (goals) {
            debugPrint(
              'GoalsBloc: emit.forEach received ${goals.length} goals',
            );
            return GoalsLoaded(goals);
          },
          onError: (error, stackTrace) {
            debugPrint('GoalsBloc: emit.forEach error: $error');
            return GoalsError(error.toString());
          },
        );
        debugPrint('GoalsBloc: emit.forEach subscription active');
      } catch (firestoreError) {
        debugPrint('GoalsBloc: Firestore connection error: $firestoreError');
        emit(GoalsError('Firestore connection failed: $firestoreError'));
        return;
      }
    } catch (e) {
      debugPrint('GoalsBloc: Exception in _onLoadGoals: $e');
      emit(GoalsError(e.toString()));
    }
  }

  Future<void> _onReloadGoals(
    ReloadGoals event,
    Emitter<GoalsState> emit,
  ) async {
    // Allow manual refresh: reset the stream and load again
    _streamInitialized = false;
    await _onLoadGoals(const LoadGoals(), emit);
  }

  Future<void> _onCreateGoal(CreateGoal event, Emitter<GoalsState> emit) async {
    final currentGoals = state is GoalsLoaded
        ? (state as GoalsLoaded).goals
        : <Goal>[];
    emit(GoalOperationInProgress(currentGoals));

    try {
      await _createGoal(event.goal);
      emit(GoalOperationSuccess(currentGoals, 'Goal created successfully'));
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }

  Future<void> _onUpdateGoal(UpdateGoal event, Emitter<GoalsState> emit) async {
    final currentGoals = state is GoalsLoaded
        ? (state as GoalsLoaded).goals
        : <Goal>[];
    emit(GoalOperationInProgress(currentGoals));

    try {
      await _updateGoal(event.goal);
      emit(GoalOperationSuccess(currentGoals, 'Goal updated successfully'));
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }

  Future<void> _onDeleteGoal(DeleteGoal event, Emitter<GoalsState> emit) async {
    final currentGoals = state is GoalsLoaded
        ? (state as GoalsLoaded).goals
        : <Goal>[];
    emit(GoalOperationInProgress(currentGoals));

    try {
      await _deleteGoal(event.goalId);
      emit(GoalOperationSuccess(currentGoals, 'Goal deleted successfully'));
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }

  Future<void> _onRefreshGoalProgress(
    RefreshGoalProgress event,
    Emitter<GoalsState> emit,
  ) async {
    try {
      await _updateGoalProgress(event.goalId, event.linkedCategories);
      // Progress updates will be reflected automatically through the stream
    } catch (e) {
      emit(GoalsError('Failed to update goal progress: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    debugPrint('GoalsBloc: close() called');
    return super.close();
  }
}
