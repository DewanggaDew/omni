import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:omni/features/transactions/presentation/widgets/transactions_list.dart';
import 'package:omni/core/widgets/app_bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OMNI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Home',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/analytics'),
                  icon: const Icon(Icons.pie_chart_rounded),
                  tooltip: 'Analytics',
                ),
                IconButton(
                  onPressed: () => context.push('/goals'),
                  icon: const Icon(Icons.flag_rounded),
                  tooltip: 'Goals',
                ),
                IconButton(
                  onPressed: () => context.push('/groups'),
                  icon: const Icon(Icons.group_rounded),
                  tooltip: 'Groups',
                ),
                IconButton(
                  onPressed: () async => FirebaseAuth.instance.signOut(),
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign out',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Expanded(child: TransactionsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
