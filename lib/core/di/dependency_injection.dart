import 'package:get_it/get_it.dart';
import '../../features/goals/data/repositories/firestore_goals_repository.dart';
import '../../features/goals/domain/repositories/goals_repository.dart';
import '../../features/goals/domain/usecases/get_goals.dart';
import '../../features/goals/domain/usecases/create_goal.dart';
import '../../features/goals/domain/usecases/update_goal.dart';
import '../../features/goals/domain/usecases/delete_goal.dart';
import '../../features/goals/domain/usecases/update_goal_progress.dart';
import '../../features/goals/presentation/bloc/goals_bloc.dart';

final sl = GetIt.instance;

void setupDependencyInjection() {
  // Goals
  sl.registerLazySingleton<GoalsRepository>(() => FirestoreGoalsRepository());

  sl.registerFactory(() => GetGoalsUseCase(sl()));
  sl.registerFactory(() => CreateGoalUseCase(sl()));
  sl.registerFactory(() => UpdateGoalUseCase(sl()));
  sl.registerFactory(() => DeleteGoalUseCase(sl()));
  sl.registerFactory(() => UpdateGoalProgressUseCase(sl()));

  sl.registerLazySingleton(
    () => GoalsBloc(
      getGoals: sl(),
      createGoal: sl(),
      updateGoal: sl(),
      deleteGoal: sl(),
      updateGoalProgress: sl(),
    ),
  );
}
