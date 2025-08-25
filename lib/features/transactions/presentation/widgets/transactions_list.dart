import 'package:flutter/material.dart';
import 'package:omni/features/transactions/data/transactions_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_docs.isEmpty) return const Center(child: Text('No transactions yet'));
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          _loadMore();
        }
        return false;
      },
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _docs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final tx = _docs[index].data();
          final amount = (tx['amount'] as int?) ?? 0;
          final type = (tx['type'] as String?) ?? 'expense';
          final note = (tx['note'] as String?) ?? '';
          return Dismissible(
            key: ValueKey(_docs[index].id),
            background: Container(color: Colors.red),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteAt(index),
            child: ListTile(
              title: Text(
                '${type == 'expense' ? '-' : '+'} ${(amount / 100).toStringAsFixed(2)}',
              ),
              subtitle: Text(note),
            ),
          );
        },
      ),
    );
  }
}
