import '../entities/goal.dart';

abstract class GoalsRepository {
  Stream<List<Goal>> getGoals(String userId);

  Future<void> createGoal(Goal goal);

  Future<void> updateGoal(Goal goal);

  Future<void> deleteGoal(String goalId);

  Future<Goal?> getGoal(String goalId);

  Future<void> updateGoalProgress(String goalId, double progress);

  Future<double> calculateGoalProgress(
    String goalId,
    List<String> linkedCategories,
  );
}
