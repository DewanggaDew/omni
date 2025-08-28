import '../repositories/goals_repository.dart';

class UpdateGoalProgressUseCase {
  final GoalsRepository repository;

  UpdateGoalProgressUseCase(this.repository);

  Future<void> call(String goalId, List<String> linkedCategories) async {
    // Calculate progress based on linked categories
    final progress = await repository.calculateGoalProgress(
      goalId,
      linkedCategories,
    );
    await repository.updateGoalProgress(goalId, progress);
  }
}
