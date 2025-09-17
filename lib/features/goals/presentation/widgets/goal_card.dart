import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/goal.dart';
import '../../../../core/utils/currency_formatter.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMonochromeIcon(theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        if (goal.description != null)
                          Text(
                            goal.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.brightness == Brightness.light
                                  ? Colors.black.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Delete'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormatter.format(
                      (goal.currentProgress * 100).round(),
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  Text(
                    'of ${CurrencyFormatter.format((goal.targetAmount * 100).round())}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.brightness == Brightness.light
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress bar
              LinearProgressIndicator(
                value: goal.progressPercentage / 100,
                backgroundColor: theme.brightness == Brightness.light
                    ? Colors.black.withOpacity(0.08)
                    : Colors.white.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Progress percentage and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.progressPercentage.toStringAsFixed(1)}% complete',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.light
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  if (goal.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Completed!',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Target date and remaining time
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.brightness == Brightness.light
                        ? Colors.black.withOpacity(0.6)
                        : Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Target: ${DateFormat.yMMMd().format(goal.targetDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.brightness == Brightness.light
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  if (!goal.isCompleted && goal.timeRemaining.inDays > 0)
                    Text(
                      '${goal.timeRemaining.inDays} days left',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.brightness == Brightness.light
                            ? Colors.black.withOpacity(0.7)
                            : Colors.white.withOpacity(0.7),
                      ),
                    )
                  else if (!goal.isCompleted)
                    Text(
                      'Overdue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),

              // Daily progress needed (if not completed)
              if (!goal.isCompleted && goal.requiredDailyProgress > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Need ${CurrencyFormatter.format((goal.requiredDailyProgress * 100).round())}/day',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonochromeIcon(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5);
    final stroke = isDark ? Colors.white : Colors.black;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: stroke.withOpacity(0.12)),
      ),
      child: Center(child: Icon(Icons.flag_outlined, color: stroke, size: 20)),
    );
  }

  // Deprecated color utility removed in monochrome redesign
}
