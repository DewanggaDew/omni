import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

class CreateGoalUseCase {
  final GoalsRepository repository;

  CreateGoalUseCase(this.repository);

  Future<void> call(Goal goal) async {
    await repository.createGoal(goal);
  }
}
