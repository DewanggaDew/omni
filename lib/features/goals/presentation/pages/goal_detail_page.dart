import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/goal.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_event.dart';
import '../bloc/goals_state.dart';
import '../widgets/manage_goal_categories_sheet.dart';

class GoalDetailPage extends StatelessWidget {
  final Goal goal;

  const GoalDetailPage({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              Navigator.of(context).pop({'action': 'edit', 'goal': goal});
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete goal?'),
                  content: const Text(
                    'This will remove the goal. Progress cannot be recovered.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                context.read<GoalsBloc>().add(DeleteGoal(goal.id));
                Navigator.of(context).pop({'action': 'deleted'});
              }
            },
            tooltip: 'Delete',
          ),
        ],
      ),
      body: BlocListener<GoalsBloc, GoalsState>(
        listener: (context, state) {
          if (state is GoalsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _Header(goal: goal),
            const SizedBox(height: 20),
            _ProgressSection(goal: goal),
            const SizedBox(height: 20),
            _MetaSection(goal: goal),
            const SizedBox(height: 20),
            _LinkedCategories(goal: goal),
            const SizedBox(height: 28),
            _Actions(goal: goal),
          ],
        ),
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
    );
  }
}

class _Header extends StatelessWidget {
  final Goal goal;
  const _Header({required this.goal});

  bool _isEmoji(String value) {
    if (value.isEmpty) return false;
    // Heuristic: detect common emoji ranges
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{1F1E6}-\u{1F1FF}]',
      unicode: true,
    );
    return emojiRegex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stroke = theme.colorScheme.onSurface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: stroke.withOpacity(0.2)),
          ),
          child: Center(
            child: Builder(
              builder: (context) {
                final iconStr = goal.icon;
                if (iconStr != null && _isEmoji(iconStr)) {
                  return Text(
                    iconStr,
                    style: TextStyle(fontSize: 22, color: stroke),
                  );
                }
                // Fallback to a clean monochrome Material icon
                return Icon(Icons.flag_outlined, color: stroke, size: 20);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (goal.description != null && goal.description!.isNotEmpty)
                Text(
                  goal.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final Goal goal;
  const _ProgressSection({required this.goal});

  String _fmt(double v) => NumberFormat.compact(locale: 'en').format(v);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = goal.progressPercentage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fmt(goal.currentProgress),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'of ${_fmt(goal.targetAmount)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: pct / 100,
          backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          minHeight: 6,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${pct.toStringAsFixed(1)}% complete',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
            Builder(
              builder: (context) {
                final tr = goal.timeRemaining.inDays;
                if (goal.isCompleted) {
                  return Text(
                    'Completed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }
                if (tr > 0) {
                  return Text(
                    '$tr days left',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  );
                }
                return Text(
                  'Overdue',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaSection extends StatelessWidget {
  final Goal goal;
  const _MetaSection({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, size: 18),
            const SizedBox(width: 6),
            Text(
              'Target: ${DateFormat.yMMMd().format(goal.targetDate)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!goal.isCompleted && goal.requiredDailyProgress > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Need ~${NumberFormat.compact().format(goal.requiredDailyProgress)} per day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LinkedCategories extends StatelessWidget {
  final Goal goal;
  const _LinkedCategories({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (goal.linkedCategories.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'No linked categories',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final result = await showModalBottomSheet<List<String>>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => ManageGoalCategoriesSheet(
                  initialSelectedIds: goal.linkedCategories,
                  goalType: goal.goalType,
                ),
              );
              if (result != null && context.mounted) {
                final updated = goal.copyWith(linkedCategories: result);
                context.read<GoalsBloc>().add(UpdateGoal(updated));
                context.read<GoalsBloc>().add(
                  RefreshGoalProgress(goal.id, result),
                );
              }
            },
            child: const Text('Link'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Linked categories',
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextButton(
              onPressed: () async {
                final result = await showModalBottomSheet<List<String>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => ManageGoalCategoriesSheet(
                    initialSelectedIds: goal.linkedCategories,
                    goalType: goal.goalType,
                  ),
                );
                if (result != null && context.mounted) {
                  final updated = goal.copyWith(linkedCategories: result);
                  context.read<GoalsBloc>().add(UpdateGoal(updated));
                  context.read<GoalsBloc>().add(
                    RefreshGoalProgress(goal.id, result),
                  );
                }
              },
              child: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: goal.linkedCategories
              .map(
                (c) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final Goal goal;
  const _Actions({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              context.read<GoalsBloc>().add(
                RefreshGoalProgress(goal.id, goal.linkedCategories),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing progress…')),
              );
            },
            child: const Text('Refresh progress'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: () {
              Navigator.of(context).pop({'action': 'edit', 'goal': goal});
            },
            child: const Text('Edit goal'),
          ),
        ),
      ],
    );
  }
}
