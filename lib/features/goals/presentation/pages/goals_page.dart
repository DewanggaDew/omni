import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../domain/entities/goal.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_event.dart';
import '../bloc/goals_state.dart';
import '../widgets/goal_card.dart';
import 'add_goal_page.dart';
import 'goal_detail_page.dart';
import '../widgets/add_goal_sheet.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.instance<GoalsBloc>()..add(const LoadGoals()),
      child: const _GoalsPageContent(),
    );
  }
}

class _GoalsPageContent extends StatefulWidget {
  const _GoalsPageContent();

  @override
  State<_GoalsPageContent> createState() => _GoalsPageContentState();
}

class _GoalsPageContentState extends State<_GoalsPageContent> {
  Timer? _refreshTimer;
  DateTime? _lastReloadAt;
  List<Goal> _cachedGoals = const [];

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // Throttle to avoid spamming
      final now = DateTime.now();
      if (_lastReloadAt == null ||
          now.difference(_lastReloadAt!).inSeconds > 10) {
        _lastReloadAt = now;
        if (mounted) {
          context.read<GoalsBloc>().add(const ReloadGoals());
        }
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _lastReloadAt = DateTime.now();
              context.read<GoalsBloc>().add(const ReloadGoals());
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openAddGoalSheet(context),
          ),
        ],
      ),
      body: BlocConsumer<GoalsBloc, GoalsState>(
        listener: (context, state) {
          if (state is GoalsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is GoalOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is GoalsLoaded) {
            _cachedGoals = state.goals;
          } else if (state is GoalOperationInProgress) {
            _cachedGoals = state.goals;
          } else if (state is GoalOperationSuccess) {
            _cachedGoals = state.goals;
          }
        },
        builder: (context, state) {
          Widget content;
          if (state is GoalsError) {
            content = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load goals',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<GoalsBloc>().add(const ReloadGoals()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            final goals = _getGoalsFromState(state);
            if (goals.isEmpty &&
                _cachedGoals.isEmpty &&
                state is GoalsLoading) {
              content = const Center(child: CircularProgressIndicator());
            } else if ((goals.isEmpty ? _cachedGoals : goals).isEmpty) {
              content = _buildEmptyState(context);
            } else {
              final list = _buildGoalsList(
                context,
                goals.isEmpty ? _cachedGoals : goals,
              );
              // Show subtle top progress bar during background refresh
              if (state is GoalsLoading &&
                  (goals.isNotEmpty || _cachedGoals.isNotEmpty)) {
                content = Column(
                  children: const [
                    LinearProgressIndicator(minHeight: 2),
                    SizedBox(height: 8),
                  ],
                );
                content = Column(
                  children: [
                    const LinearProgressIndicator(minHeight: 2),
                    const SizedBox(height: 8),
                    Expanded(child: list),
                  ],
                );
              } else {
                content = list;
              }
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              _lastReloadAt = DateTime.now();
              context.read<GoalsBloc>().add(const ReloadGoals());
              // Give the stream a moment to deliver
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: content,
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  List<Goal> _getGoalsFromState(GoalsState state) {
    if (state is GoalsLoaded) return state.goals;
    if (state is GoalOperationInProgress) return state.goals;
    if (state is GoalOperationSuccess) return state.goals;
    return [];
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Goals Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Set your first financial goal and start tracking your progress toward achieving it.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _openAddGoalSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context, List<Goal> goals) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return GoalCard(
          goal: goal,
          onTap: () => _navigateToGoalDetail(context, goal),
          onEdit: () => _navigateToEditGoal(context, goal),
          onDelete: () => _showDeleteConfirmation(context, goal),
        );
      },
    );
  }

  Future<void> _openAddGoalSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: GetIt.instance<GoalsBloc>(),
        child: const AddGoalSheet(),
      ),
    );
    if (result == true && mounted) {
      context.read<GoalsBloc>().add(const ReloadGoals());
    }
  }

  Future<void> _navigateToEditGoal(BuildContext context, Goal goal) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: GetIt.instance<GoalsBloc>(),
          child: AddGoalPage(editingGoal: goal),
        ),
      ),
    );
    if (result == true && context.mounted) {
      context.read<GoalsBloc>().add(const ReloadGoals());
    }
  }

  void _navigateToGoalDetail(BuildContext context, Goal goal) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: GetIt.instance<GoalsBloc>(),
              child: GoalDetailPage(goal: goal),
            ),
          ),
        )
        .then((result) async {
          if (!mounted) return;
          if (result is Map &&
              result['action'] == 'edit' &&
              result['goal'] is Goal) {
            await _navigateToEditGoal(context, result['goal'] as Goal);
          }
          // On delete or edit completion, refresh goals
          context.read<GoalsBloc>().add(const ReloadGoals());
        });
  }

  void _showDeleteConfirmation(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text(
          'Are you sure you want to delete "${goal.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GoalsBloc>().add(DeleteGoal(goal.id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
