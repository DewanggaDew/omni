import 'package:flutter/material.dart';
import 'package:omni/features/transactions/data/transactions_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:omni/features/transactions/presentation/pages/transaction_detail_page.dart';
import 'package:omni/core/theme/app_theme.dart';
import 'package:omni/core/utils/currency_formatter.dart';
import 'package:omni/core/services/currency_exchange_service.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key, this.onRefreshCallbackReady});

  final ValueChanged<VoidCallback>? onRefreshCallbackReady;

  @override
  Widget build(BuildContext context) {
    final repo = TransactionsRepository();
    Query<Map<String, dynamic>> query = repo.buildLatestQuery(limit: 20);
    return _PagedTransactionsList(
      query: query,
      repo: repo,
      onRefreshCallbackReady: onRefreshCallbackReady,
    );
  }
}

class _PagedTransactionsList extends StatefulWidget {
  const _PagedTransactionsList({
    required this.query,
    required this.repo,
    this.onRefreshCallbackReady,
  });

  final Query<Map<String, dynamic>> query;
  final TransactionsRepository repo;
  final ValueChanged<VoidCallback>? onRefreshCallbackReady;

  @override
  State<_PagedTransactionsList> createState() => _PagedTransactionsListState();
}

class _PagedTransactionsListState extends State<_PagedTransactionsList> {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String _userCurrency = 'IDR';

  @override
  void initState() {
    super.initState();
    _loadUserCurrency();
    _load();

    // Register the refresh callback with the parent
    widget.onRefreshCallbackReady?.call(refresh);
  }

  Future<void> _loadUserCurrency() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['currency'] != null) {
            setState(() {
              _userCurrency = data['currency'] as String;
            });
          }
        }
      } catch (e) {
        debugPrint('Failed to load user currency: $e');
      }
    }
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

  /// Public method to refresh the transactions list
  /// Can be called from parent widgets to update the list
  void refresh() {
    _load();
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
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              'No transactions yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
        separatorBuilder: (_, __) => const SizedBox(height: AppTheme.space8),
        itemBuilder: (context, index) {
          final tx = _docs[index].data();
          final amount = (tx['amount'] as int?) ?? 0;
          final type = (tx['type'] as String?) ?? 'expense';
          final note = (tx['note'] as String?) ?? '';
          final date = tx['date'] as Timestamp?;
          final transactionCurrency = (tx['currency'] as String?) ?? 'IDR';

          // Convert amount if currencies differ
          final displayAmount = transactionCurrency != _userCurrency
              ? CurrencyExchangeService.convert(
                  amountMinor: amount,
                  fromCurrency: transactionCurrency,
                  toCurrency: _userCurrency,
                )
              : amount;

          return Dismissible(
            key: ValueKey(_docs[index].id),
            background: Container(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
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
              leading: Icon(
                type == 'expense'
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                color: type == 'expense'
                    ? AppTheme.warmRed
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                size: 22,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CurrencyFormatter.formatWithSign(
                      displayAmount,
                      type,
                      currencyCode: _userCurrency,
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: type == 'expense'
                          ? AppTheme.warmRed
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (transactionCurrency != _userCurrency) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Originally: ${CurrencyFormatter.formatWithSign(amount, type, currencyCode: transactionCurrency)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
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
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionDetailPage(id: _docs[index].id),
                      ),
                    );
                    // Refresh the list if the transaction was updated
                    if (result == true && mounted) {
                      refresh();
                    }
                  } else if (value == 'duplicate') {
                    await TransactionsRepository().duplicate(_docs[index].id);
                    refresh(); // Refresh after duplicate
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
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TransactionDetailPage(id: _docs[index].id),
                  ),
                );
                // Refresh the list if the transaction was updated
                if (result == true && mounted) {
                  refresh();
                }
              },
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
