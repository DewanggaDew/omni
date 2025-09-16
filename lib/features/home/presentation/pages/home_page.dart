import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:omni/features/transactions/presentation/widgets/transactions_list.dart';
import 'package:omni/core/widgets/app_bottom_nav.dart';
import 'package:omni/features/home/presentation/widgets/home_header.dart';
import 'package:omni/core/theme/app_theme.dart';
import 'package:omni/core/widgets/app_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  VoidCallback? _homeHeaderRefreshCallback;
  VoidCallback? _transactionsListRefreshCallback;

  Future<void> _navigateToAddTransaction() async {
    final result = await context.push('/add');

    // If a transaction was successfully added, refresh both the header and transactions list
    if (result == true && mounted) {
      _homeHeaderRefreshCallback?.call();
      _transactionsListRefreshCallback?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeader(
              onRefreshCallbackReady: (callback) {
                _homeHeaderRefreshCallback = callback;
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.space24,
              AppTheme.space32,
              AppTheme.space24,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.vibrantBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Text(
                        'Recent transactions',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space8),
                  Text(
                    'Your latest financial activity',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
            sliver: SliverToBoxAdapter(
              child: AppCard(
                padding: EdgeInsets.zero,
                child: TransactionsList(
                  onRefreshCallbackReady: (callback) {
                    _transactionsListRefreshCallback = callback;
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.space24)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        elevation: 0,
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.deepBlack,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 24),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
