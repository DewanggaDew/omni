import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omni/core/theme/app_theme.dart';
import 'package:omni/core/theme/theme_cubit.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space24,
          AppTheme.space48,
          AppTheme.space24,
          AppTheme.space40,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppTheme.deepBlack.withOpacity(0.6)
                  : AppTheme.deepBlack.withOpacity(0.08),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: isDark
                  ? AppTheme.deepBlack.withOpacity(0.3)
                  : AppTheme.deepBlack.withOpacity(0.04),
              blurRadius: 48,
              spreadRadius: 0,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good ${_getTimeGreeting()}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space8),
                      Text(
                        user?.displayName ?? 'Welcome back',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.charcoalBlack
                            : AppTheme.offWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => _showThemeSelector(context),
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        iconSize: 20,
                        tooltip: 'Change theme',
                      ),
                    ),
                    const SizedBox(width: AppTheme.space8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.charcoalBlack
                            : AppTheme.offWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => context.go('/settings'),
                        icon: const Icon(Icons.person_outline_rounded),
                        iconSize: 20,
                        tooltip: 'Settings',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space40),
            _buildSpendingSummary(context),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.space24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusXL),
            topRight: Radius.circular(AppTheme.radiusXL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.space24),
            Text(
              'Theme',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppTheme.space24),
            _ThemeOption(
              title: 'System',
              subtitle: 'Follow system setting',
              icon: Icons.settings_rounded,
              mode: ThemeMode.system,
              cubit: themeCubit,
            ),
            const SizedBox(height: AppTheme.space12),
            _ThemeOption(
              title: 'Light',
              subtitle: 'Light theme',
              icon: Icons.light_mode_rounded,
              mode: ThemeMode.light,
              cubit: themeCubit,
            ),
            const SizedBox(height: AppTheme.space12),
            _ThemeOption(
              title: 'Dark',
              subtitle: 'Dark theme',
              icon: Icons.dark_mode_rounded,
              mode: ThemeMode.dark,
              cubit: themeCubit,
            ),
            SizedBox(
              height:
                  MediaQuery.of(context).viewInsets.bottom + AppTheme.space24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingSummary(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Today',
            amount: 'IDR 0',
            subtitle: 'No expenses yet',
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppTheme.space16),
        Expanded(
          child: _SummaryCard(
            title: 'This month',
            amount: 'IDR 0',
            subtitle: 'vs IDR 0 budget',
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String amount;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(isDark ? 0.15 : 0.08),
            color.withOpacity(isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.25 : 0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.1 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            amount,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.mode,
    required this.cubit,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode mode;
  final ThemeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentMode) {
        final isSelected = currentMode == mode;

        return GestureDetector(
          onTap: () {
            cubit.setTheme(mode);
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppTheme.charcoalBlack : AppTheme.offWhite)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: isSelected
                    ? AppTheme.vibrantBlue.withOpacity(0.3)
                    : theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.vibrantBlue.withOpacity(0.1)
                        : theme.colorScheme.outline.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppTheme.vibrantBlue
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    color: AppTheme.vibrantBlue,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
