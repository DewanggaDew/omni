import 'package:flutter/material.dart';
import 'package:omni/features/transactions/data/transactions_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omni/features/transactions/presentation/pages/transaction_detail_page.dart';
import 'package:omni/core/theme/app_theme.dart';
import 'package:omni/core/utils/currency_formatter.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = TransactionsRepository();
    Query<Map<String, dynamic>> query = repo.buildLatestQuery(limit: 20);
    return _PagedTransactionsList(query: query, repo: repo);
  }
}

class _PagedTransactionsList extends StatefulWidget {
  const _PagedTransactionsList({required this.query, required this.repo});
  final Query<Map<String, dynamic>> query;
  final TransactionsRepository repo;

  @override
  State<_PagedTransactionsList> createState() => _PagedTransactionsListState();
}

class _PagedTransactionsListState extends State<_PagedTransactionsList> {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final snap = await widget.query.get();
    setState(() {
      _docs.clear();
      _docs.addAll(snap.docs);
      _hasMore = snap.docs.length >= 20;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _docs.isEmpty) return;
    setState(() => _loadingMore = true);
    final last = _docs.last;
    final snap = await widget.query.startAfterDocument(last).get();
    setState(() {
      _docs.addAll(snap.docs);
      _hasMore = snap.docs.length >= 20;
      _loadingMore = false;
    });
  }

  Future<void> _deleteAt(int index) async {
    final d = _docs[index];
    final backup = d.data();
    setState(() => _docs.removeAt(index));
    await widget.repo.delete(id: d.id, backup: backup);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            // Restore
            await FirebaseFirestore.instance
                .collection(d.reference.parent.path)
                .add(backup);
            await _load();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_docs.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              'No transactions yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              'Tap + to add your first expense',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          _loadMore();
        }
        return false;
      },
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _docs.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        itemBuilder: (context, index) {
          final tx = _docs[index].data();
          final amount = (tx['amount'] as int?) ?? 0;
          final type = (tx['type'] as String?) ?? 'expense';
          final note = (tx['note'] as String?) ?? '';
          final date = tx['date'] as Timestamp?;

          return Dismissible(
            key: ValueKey(_docs[index].id),
            background: Container(
              color: theme.colorScheme.error.withOpacity(0.1),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppTheme.space24),
              child: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteAt(index),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space20,
                vertical: AppTheme.space8,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      (type == 'expense'
                              ? AppTheme.warmRed
                              : AppTheme.emeraldGreen)
                          .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(
                    color:
                        (type == 'expense'
                                ? AppTheme.warmRed
                                : AppTheme.emeraldGreen)
                            .withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  type == 'expense'
                      ? Icons.trending_down_rounded
                      : Icons.trending_up_rounded,
                  color: type == 'expense'
                      ? AppTheme.warmRed
                      : AppTheme.emeraldGreen,
                  size: 22,
                ),
              ),
              title: Text(
                CurrencyFormatter.formatWithSign(
                  amount,
                  type == 'expense' ? '-' : '+',
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: type == 'expense'
                      ? AppTheme.warmRed
                      : AppTheme.emeraldGreen,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.space4),
                    Text(note, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: AppTheme.space4),
                  Text(
                    date != null ? _formatDate(date.toDate()) : 'Just now',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.colorScheme.outline),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionDetailPage(id: _docs[index].id),
                      ),
                    );
                  } else if (value == 'duplicate') {
                    TransactionsRepository().duplicate(_docs[index].id);
                  } else if (value == 'delete') {
                    _deleteAt(index);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransactionDetailPage(id: _docs[index].id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (txDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
