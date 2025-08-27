import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:omni/features/transactions/presentation/widgets/transactions_list.dart';
import 'package:omni/core/widgets/app_bottom_nav.dart';
import 'package:omni/features/home/presentation/widgets/home_header.dart';
import 'package:omni/core/theme/app_theme.dart';
import 'package:omni/core/widgets/app_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: HomeHeader()),
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
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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
            sliver: const SliverToBoxAdapter(
              child: AppCard(
                padding: EdgeInsets.zero,
                child: TransactionsList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.space24)),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppTheme.vibrantBlue.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.vibrantBlue.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/add'),
          elevation: 0,
          backgroundColor: AppTheme.vibrantBlue,
          foregroundColor: AppTheme.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          icon: const Icon(Icons.add_rounded, size: 24),
          label: Text(
            'Add',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.pureWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
