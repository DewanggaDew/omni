import 'package:equatable/equatable.dart';
import '../../domain/entities/goal.dart';

abstract class GoalsEvent extends Equatable {
  const GoalsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalsEvent {
  const LoadGoals();
}

class CreateGoal extends GoalsEvent {
  final Goal goal;

  const CreateGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class UpdateGoal extends GoalsEvent {
  final Goal goal;

  const UpdateGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class DeleteGoal extends GoalsEvent {
  final String goalId;

  const DeleteGoal(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

class RefreshGoalProgress extends GoalsEvent {
  final String goalId;
  final List<String> linkedCategories;

  const RefreshGoalProgress(this.goalId, this.linkedCategories);

  @override
  List<Object?> get props => [goalId, linkedCategories];
}
