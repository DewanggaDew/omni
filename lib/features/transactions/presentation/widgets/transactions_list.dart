import 'package:flutter/material.dart';
import 'package:omni/features/transactions/data/transactions_repository.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = TransactionsRepository();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: repo.watchLatest(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return const Center(child: Text('No transactions yet'));
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final tx = items[index];
            final amount = (tx['amount'] as int?) ?? 0;
            final type = (tx['type'] as String?) ?? 'expense';
            final note = (tx['note'] as String?) ?? '';
            return ListTile(
              title: Text(
                '${type == 'expense' ? '-' : '+'} ${(amount / 100).toStringAsFixed(2)}',
              ),
              subtitle: Text(note),
            );
          },
        );
      },
    );
  }
}
