import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String _selectedCurrency = 'IDR';

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
              _selectedCurrency = data['currency'] as String;
            });
          }
        }
      } catch (e) {
        // Use default currency if loading fails
        debugPrint('Failed to load user currency: $e');
      }
    }
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
        currency: _selectedCurrency,
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
        print(
          'DEBUG: Add page - transaction saved successfully, returning true',
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    children: [
                      // Amount Field
                      _buildFormField(
                        child: TextFormField(
                          controller: _amountController,
                          decoration: _buildInputDecoration(
                            context,
                            'Amount ($_selectedCurrency)',
                            'e.g. 12.50',
                          ),
                          style: _buildTextStyle(context),
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
                      ),

                      // Type Field
                      _buildFormField(
                        child: DropdownButtonFormField<String>(
                          initialValue: _type,
                          items: [
                            DropdownMenuItem(
                              value: 'expense',
                              child: Text(
                                'Expense',
                                style: _buildTextStyle(context),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'income',
                              child: Text(
                                'Income',
                                style: _buildTextStyle(context),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _type = v ?? 'expense'),
                          decoration: _buildInputDecoration(context, 'Type'),
                          dropdownColor: _buildDropdownColor(context),
                          style: _buildTextStyle(context),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),

                      // Category Field
                      _buildFormField(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: CategoriesRepository().watchAll(),
                          builder: (context, snapshot) {
                            final cats = snapshot.data ?? const [];
                            return DropdownButtonFormField<String>(
                              initialValue: _categoryId,
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'No category',
                                    style: _buildTextStyle(context),
                                  ),
                                ),
                                ...cats.map(
                                  (c) => DropdownMenuItem(
                                    value: c['id'] as String,
                                    child: Text(
                                      '${c['emoji'] ?? ''} ${c['name']}',
                                      style: _buildTextStyle(context),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(() => _categoryId = v),
                              decoration: _buildInputDecoration(
                                context,
                                'Category',
                              ),
                              dropdownColor: _buildDropdownColor(context),
                              style: _buildTextStyle(context),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Date & Time Field
                      _buildFormField(
                        child: InkWell(
                          onTap: () async {
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
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.space12,
                              vertical: AppTheme.space16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusS,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date & time',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.7),
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: AppTheme.space4),
                                      Text(
                                        _formatDateTime(_date),
                                        style: _buildTextStyle(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Note Field
                      _buildFormField(
                        child: TextFormField(
                          controller: _noteController,
                          decoration: _buildInputDecoration(
                            context,
                            'Note',
                            'Optional',
                          ),
                          style: _buildTextStyle(context),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space32),
                // Button Section
                Column(
                  children: [
                    // Main Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _loading ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          disabledBackgroundColor: theme.colorScheme.primary
                              .withValues(alpha: 0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusM,
                            ),
                          ),
                        ),
                        child: _loading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                'Save Transaction',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.space16),

                    // Save & Add Another Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _loading
                            ? null
                            : () {
                                setState(() => _saveAndAddAnother = true);
                                _save().whenComplete(
                                  () => _saveAndAddAnother = false,
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          disabledForegroundColor: theme.colorScheme.primary
                              .withValues(alpha: 0.6),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withValues(
                              alpha: _loading ? 0.3 : 0.6,
                            ),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusM,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: theme.colorScheme.primary.withValues(
                                alpha: _loading ? 0.6 : 1.0,
                              ),
                            ),
                            const SizedBox(width: AppTheme.space8),
                            Text(
                              'Save & Add Another',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: _loading ? 0.6 : 1.0,
                                ),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for consistent styling
  Widget _buildFormField({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space20),
      child: child,
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context,
    String label, [
    String? hint,
  ]) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        fontWeight: FontWeight.w500,
      ),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space12,
        vertical: AppTheme.space16,
      ),
      filled: false,
    );
  }

  TextStyle _buildTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ) ??
        TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        );
  }

  Color _buildDropdownColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? AppTheme.charcoalBlack : theme.colorScheme.surface;
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
