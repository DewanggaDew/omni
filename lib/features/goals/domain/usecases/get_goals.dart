import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

class GetGoalsUseCase {
  final GoalsRepository repository;

  GetGoalsUseCase(this.repository);

  Stream<List<Goal>> call(String userId) {
    return repository.getGoals(userId);
  }
}
