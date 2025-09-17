import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:omni/core/theme/app_theme.dart';
import 'package:omni/features/categories/data/categories_repository.dart';
import 'package:omni/features/transactions/data/transactions_repository.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  String? _categoryId;
  DateTime _date = DateTime.now();
  bool _saving = false;
  String _currency = 'IDR';

  @override
  void initState() {
    super.initState();
    _loadUserCurrency();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCurrency() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null && data['currency'] != null) {
        setState(() => _currency = data['currency'] as String);
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = TransactionsRepository();
      final amountMinor = (double.parse(_amountController.text.trim()) * 100)
          .round();
      await repo.add(
        amountMinor: amountMinor,
        type: _type,
        date: _date,
        categoryId: _categoryId,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        currency: _currency,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (!mounted) return;
    setState(() {
      final time = t ?? TimeOfDay.fromDateTime(_date);
      _date = DateTime(d.year, d.month, d.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusXL),
              topRight: Radius.circular(AppTheme.radiusXL),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.space24,
              AppTheme.space16,
              AppTheme.space24,
              AppTheme.space24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space16),
                  Text(
                    'Add Transaction',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space16),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount ($_currency)',
                      hintText: 'e.g., 12.50',
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter amount';
                      final parsed = double.tryParse(v.trim());
                      if (parsed == null || parsed <= 0)
                        return 'Enter valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.space12),
                  DropdownButtonFormField<String>(
                    value: _type,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    iconEnabledColor: theme.colorScheme.onSurface.withOpacity(
                      0.85,
                    ),
                    iconDisabledColor: theme.colorScheme.onSurface.withOpacity(
                      0.6,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'expense',
                        child: Text('Expense'),
                      ),
                      DropdownMenuItem(value: 'income', child: Text('Income')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'expense'),
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.black.withOpacity(0.04),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space12,
                        vertical: AppTheme.space12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space12),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: CategoriesRepository().watchAll(),
                    builder: (context, snapshot) {
                      final cats = (snapshot.data ?? const [])
                          .where(
                            (c) =>
                                (_type == 'expense' &&
                                    (c['type'] == 'expense')) ||
                                (_type == 'income' && (c['type'] == 'income')),
                          )
                          .toList();
                      return DropdownButtonFormField<String>(
                        value: _categoryId,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        iconEnabledColor: theme.colorScheme.onSurface
                            .withOpacity(0.85),
                        iconDisabledColor: theme.colorScheme.onSurface
                            .withOpacity(0.6),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('No category'),
                          ),
                          ...cats.map(
                            (c) => DropdownMenuItem(
                              value: c['id'] as String,
                              child: Text(
                                '${c['emoji'] ?? ''} ${c['name']}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.black.withOpacity(0.04),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.space12,
                            vertical: AppTheme.space12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusS,
                            ),
                            borderSide: BorderSide(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusS,
                            ),
                            borderSide: BorderSide(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusS,
                            ),
                            borderSide: BorderSide(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.9,
                              ),
                              width: 1.2,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null) return null; // allow no category
                          final selected = (snapshot.data ?? const [])
                              .firstWhere(
                                (c) => c['id'] == v,
                                orElse: () => {},
                              );
                          final t = selected['type'];
                          if (t != _type) {
                            return 'Select a ${_type == 'expense' ? 'expense' : 'income'} category';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.space12),
                  InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space12,
                        vertical: AppTheme.space16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date & time',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.space4),
                                Text(
                                  _date.toLocal().toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space12),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppTheme.space24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Transaction'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
