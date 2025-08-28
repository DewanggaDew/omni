import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

class UpdateGoalUseCase {
  final GoalsRepository repository;

  UpdateGoalUseCase(this.repository);

  Future<void> call(Goal goal) async {
    await repository.updateGoal(goal);
  }
}
