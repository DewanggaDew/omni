import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omni/features/transactions/data/transactions_repository.dart';
import 'package:omni/core/theme/app_theme.dart';
import 'package:omni/core/widgets/app_card.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({super.key, required this.id});
  final String id;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  bool _loading = true;
  DateTime _date = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _load();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = TransactionsRepository();
    final data = await repo.fetchById(widget.id);
    if (data != null) {
      setState(() {
        _type = (data['type'] as String?) ?? 'expense';
        final amount = (data['amount'] as int?) ?? 0;
        _amountController.text = (amount / 100).toStringAsFixed(2);
        _noteController.text = (data['note'] as String?) ?? '';
        final ts = data['date'];
        if (ts is Timestamp) _date = ts.toDate();
        _loading = false;
      });
      _animationController.forward();
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Haptic feedback for save action
    HapticFeedback.lightImpact();

    setState(() => _loading = true);
    final repo = TransactionsRepository();
    final amountMinor = (double.parse(_amountController.text) * 100).round();
    await repo.update(
      id: widget.id,
      amountMinor: amountMinor,
      type: _type,
      date: _date,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    if (!mounted) return;

    // Success haptic feedback
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  Future<void> _duplicate() async {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    await TransactionsRepository().duplicate(widget.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          'Transaction Details',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          _buildActionButton(
            icon: Icons.copy_rounded,
            onPressed: _duplicate,
            tooltip: 'Duplicate',
          ),
          const SizedBox(width: AppTheme.space8),
          _buildActionButton(
            icon: Icons.check_rounded,
            onPressed: _save,
            tooltip: 'Save',
            isPrimary: true,
          ),
          const SizedBox(width: AppTheme.space16),
        ],
      ),
      body: _loading
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.space24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.charcoalBlack : AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? AppTheme.deepBlack.withValues(alpha: 0.6)
                          : AppTheme.deepBlack.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.space24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAmountSection(theme),
                      const SizedBox(height: AppTheme.space24),
                      _buildTypeSection(theme),
                      const SizedBox(height: AppTheme.space24),
                      _buildDateSection(theme),
                      const SizedBox(height: AppTheme.space24),
                      _buildNoteSection(theme),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: isPrimary
            ? AppTheme.vibrantBlue
            : (isDark ? AppTheme.charcoalBlack : AppTheme.offWhite),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: isPrimary
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
        boxShadow: [
          if (isPrimary) ...[
            BoxShadow(
              color: AppTheme.vibrantBlue.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppTheme.vibrantBlue.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ] else ...[
            BoxShadow(
              color: isDark
                  ? AppTheme.deepBlack.withValues(alpha: 0.3)
                  : AppTheme.deepBlack.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: isPrimary
              ? AppTheme.pureWhite
              : theme.colorScheme.onSurface.withValues(alpha: 0.8),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildAmountSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space8,
                  vertical: AppTheme.space4,
                ),
                decoration: BoxDecoration(
                  color: _type == 'expense'
                      ? AppTheme.warmRed.withValues(alpha: 0.1)
                      : AppTheme.emeraldGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  'Amount',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _type == 'expense'
                        ? AppTheme.warmRed
                        : AppTheme.emeraldGreen,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space16,
              vertical: AppTheme.space16,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkGrey : AppTheme.offWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${_type == 'expense' ? '-' : '+'}IDR',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: _type == 'expense'
                        ? AppTheme.warmRed
                        : AppTheme.emeraldGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _type == 'expense'
                          ? AppTheme.warmRed
                          : AppTheme.emeraldGreen,
                      letterSpacing: -0.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => v == null || double.tryParse(v) == null
                        ? 'Enter amount'
                        : null,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection(ThemeData theme) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space8,
              vertical: AppTheme.space4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.vibrantBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Text(
              'Transaction Type',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.vibrantBlue,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space20),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  'expense',
                  'Expense',
                  Icons.trending_down_rounded,
                  AppTheme.warmRed,
                  theme,
                ),
              ),
              const SizedBox(width: AppTheme.space16),
              Expanded(
                child: _buildTypeOption(
                  'income',
                  'Income',
                  Icons.trending_up_rounded,
                  AppTheme.emeraldGreen,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    String value,
    String label,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    final isSelected = _type == value;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _type = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppTheme.space20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isDark ? AppTheme.charcoalBlack : AppTheme.offWhite),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.4)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected) ...[
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] else ...[
              BoxShadow(
                color: isDark
                    ? AppTheme.deepBlack.withValues(alpha: 0.2)
                    : AppTheme.deepBlack.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.space8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : theme.colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? color
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: AppTheme.space12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected
                    ? color
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: () => _showDateTimePicker(),
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space8,
              vertical: AppTheme.space4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.vibrantBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Text(
              'Date & Time',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.vibrantBlue,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space20),
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkGrey : AppTheme.offWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space8),
                  decoration: BoxDecoration(
                    color: AppTheme.vibrantBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: AppTheme.vibrantBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: Text(
                    _formatDateTime(_date),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space8,
              vertical: AppTheme.space4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.vibrantBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Text(
              'Note (Optional)',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.vibrantBlue,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space20),
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkGrey : AppTheme.offWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: TextFormField(
              controller: _noteController,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
              decoration: InputDecoration(
                hintText: 'Add details about this transaction...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.4,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateTimePicker() async {
    HapticFeedback.lightImpact();

    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.vibrantBlue),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.vibrantBlue),
          ),
          child: child!,
        );
      },
    );

    setState(() {
      final selectedTime = time ?? TimeOfDay.fromDateTime(_date);
      _date = DateTime(
        date.year,
        date.month,
        date.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeString = TimeOfDay.fromDateTime(dateTime).format(context);

    if (targetDate == today) {
      return 'Today at $timeString';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at $timeString';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow at $timeString';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at $timeString';
    }
  }
}
