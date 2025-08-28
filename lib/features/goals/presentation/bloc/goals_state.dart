import 'package:equatable/equatable.dart';
import '../../domain/entities/goal.dart';

abstract class GoalsState extends Equatable {
  const GoalsState();

  @override
  List<Object?> get props => [];
}

class GoalsInitial extends GoalsState {
  const GoalsInitial();
}

class GoalsLoading extends GoalsState {
  const GoalsLoading();
}

class GoalsLoaded extends GoalsState {
  final List<Goal> goals;

  const GoalsLoaded(this.goals);

  @override
  List<Object?> get props => [goals];
}

class GoalsError extends GoalsState {
  final String message;

  const GoalsError(this.message);

  @override
  List<Object?> get props => [message];
}

class GoalOperationInProgress extends GoalsState {
  final List<Goal> goals;

  const GoalOperationInProgress(this.goals);

  @override
  List<Object?> get props => [goals];
}

class GoalOperationSuccess extends GoalsState {
  final List<Goal> goals;
  final String message;

  const GoalOperationSuccess(this.goals, this.message);

  @override
  List<Object?> get props => [goals, message];
}
