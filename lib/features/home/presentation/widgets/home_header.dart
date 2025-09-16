import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omni/core/theme/app_theme.dart';
import 'package:omni/core/theme/theme_cubit.dart';
import 'package:omni/core/utils/currency_formatter.dart';
import 'package:omni/core/services/currency_exchange_service.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key, this.onRefreshCallbackReady});

  final ValueChanged<VoidCallback>? onRefreshCallbackReady;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String _userCurrency = 'IDR';
  int _todayTotal = 0;
  int _monthTotal = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSummaryData();

    // Register the refresh callback with the parent
    widget.onRefreshCallbackReady?.call(refresh);
  }

  Future<void> _loadSummaryData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Load user currency preference
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['currency'] != null) {
          _userCurrency = data['currency'] as String;
        }
      }

      // Load expenses - get all expenses first, then filter by date
      final expenseQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('type', isEqualTo: 'expense')
          .get();

      // Calculate totals with currency conversion
      int todayTotal = 0;
      int monthTotal = 0;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1);

      for (final doc in expenseQuery.docs) {
        final data = doc.data();
        final amount = (data['amount'] as int?) ?? 0;
        final transactionCurrency = (data['currency'] as String?) ?? 'IDR';
        final timestamp = (data['date'] as Timestamp?);

        if (timestamp == null) continue;
        final transactionDate = timestamp.toDate();

        final convertedAmount = transactionCurrency != _userCurrency
            ? CurrencyExchangeService.convert(
                amountMinor: amount,
                fromCurrency: transactionCurrency,
                toCurrency: _userCurrency,
              )
            : amount;

        // Since expenses are stored as negative values, we need the absolute value for summary
        final absAmount = convertedAmount.abs();

        // Check if transaction is today
        if (transactionDate.isAfter(todayStart) &&
            transactionDate.isBefore(todayEnd)) {
          todayTotal += absAmount;
        }

        // Check if transaction is this month
        if (transactionDate.isAfter(monthStart) &&
            transactionDate.isBefore(monthEnd)) {
          monthTotal += absAmount;
        }
      }

      setState(() {
        _todayTotal = todayTotal;
        _monthTotal = monthTotal;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading summary data: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  /// Public method to refresh the summary data
  /// Can be called from parent widgets to update the header
  void refresh() {
    _loadSummaryData();
  }

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
        color: Colors.transparent,
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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
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
                    IconButton(
                      onPressed: () => _showThemeSelector(context),
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      iconSize: 20,
                      tooltip: 'Change theme',
                    ),
                    IconButton(
                      onPressed: () => context.go('/settings'),
                      icon: Icon(
                        Icons.person_outline_rounded,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      iconSize: 20,
                      tooltip: 'Settings',
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
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
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

    if (_loading) {
      return Row(
        children: [
          Expanded(
            child: _SummaryCard(
              title: 'Today',
              amount: '--',
              subtitle: 'Loading...',
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppTheme.space16),
          Expanded(
            child: _SummaryCard(
              title: 'This month',
              amount: '--',
              subtitle: 'Loading...',
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      );
    }

    final todayFormatted = _todayTotal > 0
        ? CurrencyFormatter.formatCompact(
            _todayTotal,
            currencyCode: _userCurrency,
          )
        : CurrencyFormatter.format(0, currencyCode: _userCurrency);

    final monthFormatted = _monthTotal > 0
        ? CurrencyFormatter.formatCompact(
            _monthTotal,
            currencyCode: _userCurrency,
          )
        : CurrencyFormatter.format(0, currencyCode: _userCurrency);

    final todaySubtitle = _todayTotal > 0 ? 'Spent today' : 'No expenses yet';
    final monthSubtitle = _monthTotal > 0
        ? 'Spent this month'
        : 'No expenses this month';

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Today',
            amount: todayFormatted,
            subtitle: todaySubtitle,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppTheme.space16),
        Expanded(
          child: _SummaryCard(
            title: 'This month',
            amount: monthFormatted,
            subtitle: monthSubtitle,
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

    // Determine text size based on amount length for better responsive design
    final isLongAmount = amount.length > 10;
    final amountTextStyle = isLongAmount
        ? theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          )
        : theme.textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          );

    return Container(
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.15 : 0.08),
            color.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.1 : 0.06),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: amountTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                    ? AppTheme.vibrantBlue.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.vibrantBlue.withValues(alpha: 0.1)
                        : theme.colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppTheme.vibrantBlue
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
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
