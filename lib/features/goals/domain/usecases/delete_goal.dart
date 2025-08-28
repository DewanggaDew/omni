import '../repositories/goals_repository.dart';

class DeleteGoalUseCase {
  final GoalsRepository repository;

  DeleteGoalUseCase(this.repository);

  Future<void> call(String goalId) async {
    await repository.deleteGoal(goalId);
  }
}
