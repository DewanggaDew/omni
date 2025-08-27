import 'package:flutter/material.dart';
import 'package:omni/features/transactions/data/transactions_repository.dart';
import 'package:omni/features/categories/data/categories_repository.dart';
import 'package:omni/core/widgets/app_card.dart';
import 'package:omni/core/theme/app_theme.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  String? _categoryId;
  bool _loading = false;
  bool _saveAndAddAnother = false;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = TransactionsRepository();
      final amountMinor = (double.parse(_amountController.text) * 100).round();
      await repo.add(
        amountMinor: amountMinor,
        type: _type,
        date: _date,
        categoryId: _categoryId,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved')));
      if (_saveAndAddAnother) {
        _amountController.clear();
        _noteController.clear();
        setState(() {
          _type = 'expense';
        });
      } else {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (e.g. 12.50)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter amount';
                        final parsed = double.tryParse(v);
                        if (parsed == null || parsed <= 0) {
                          return 'Enter valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.space12),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      items: const [
                        DropdownMenuItem(
                          value: 'expense',
                          child: Text('Expense'),
                        ),
                        DropdownMenuItem(
                          value: 'income',
                          child: Text('Income'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? 'expense'),
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    const SizedBox(height: AppTheme.space12),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: CategoriesRepository().watchAll(),
                      builder: (context, snapshot) {
                        final cats = snapshot.data ?? const [];
                        return DropdownButtonFormField<String>(
                          initialValue: _categoryId,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('No category'),
                            ),
                            ...cats.map(
                              (c) => DropdownMenuItem(
                                value: c['id'] as String,
                                child: Text('${c['emoji'] ?? ''} ${c['name']}'),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _categoryId = v),
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppTheme.space12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date & time'),
                      subtitle: Text('${_date.toLocal()}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (d == null) return;
                          final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_date),
                          );
                          setState(() {
                            final time = t ?? TimeOfDay.fromDateTime(_date);
                            _date = DateTime(
                              d.year,
                              d.month,
                              d.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.space12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading ? null : _save,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() => _saveAndAddAnother = true);
                              _save().whenComplete(
                                () => _saveAndAddAnother = false,
                              );
                            },
                      child: const Text('Save & add another'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
