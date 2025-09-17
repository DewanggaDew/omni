import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/goal.dart';
import 'package:omni/core/theme/app_theme.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_event.dart';
import '../bloc/goals_state.dart';

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedIconKey = 'flag';
  String _goalType = 'saving'; // 'saving' | 'budget'
  bool _saving = false;

  static const Map<String, IconData> _iconMap = {
    'flag': Icons.flag_outlined,
    'savings': Icons.savings_outlined,
    'home': Icons.home_outlined,
    'car': Icons.directions_car_outlined,
    'flight': Icons.flight_outlined,
    'school': Icons.school_outlined,
    'diamond': Icons.diamond_outlined,
    'beach': Icons.beach_access_outlined,
    'phone': Icons.smartphone_outlined,
    'laptop': Icons.laptop_outlined,
    'music': Icons.music_note_outlined,
    'books': Icons.menu_book_outlined,
    'fitness': Icons.fitness_center_outlined,
    'apple': Icons.apple_outlined,
    'palette': Icons.palette_outlined,
    'bolt': Icons.bolt_outlined,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _saving = false);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final goal = Goal(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.uid,
      name: _nameController.text.trim(),
      description: null,
      goalType: _goalType,
      targetAmount: amount,
      targetDate: DateTime.now().add(const Duration(days: 365)),
      linkedCategories: const [],
      currentProgress: 0,
      autoCompute: true,
      createdAt: DateTime.now(),
      color: null,
      icon: _selectedIconKey,
    );

    context.read<GoalsBloc>().add(CreateGoal(goal));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<GoalsBloc, GoalsState>(
      listener: (context, state) {
        if (state is GoalOperationInProgress) {
          setState(() => _saving = true);
        } else if (state is GoalOperationSuccess) {
          setState(() => _saving = false);
          Navigator.of(context).pop(true);
        } else if (state is GoalsError) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: SafeArea(
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
                    DropdownButtonFormField<String>(
                      value: _goalType,
                      items: const [
                        DropdownMenuItem(
                          value: 'saving',
                          child: Text('Saving goal'),
                        ),
                        DropdownMenuItem(
                          value: 'budget',
                          child: Text('Budget goal'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _goalType = v ?? 'saving'),
                      decoration: const InputDecoration(labelText: 'Goal type'),
                    ),
                    const SizedBox(height: AppTheme.space16),
                    Text(
                      'Add Goal',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Goal title',
                        hintText: 'e.g., Emergency fund',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter a title'
                          : null,
                    ),
                    const SizedBox(height: AppTheme.space16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Target amount',
                        hintText: 'e.g., 1500000',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter an amount';
                        }
                        final parsed = double.tryParse(v.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.space20),
                    Text(
                      'Icon',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space12),
                    Wrap(
                      spacing: AppTheme.space12,
                      runSpacing: AppTheme.space12,
                      children: _iconMap.entries.map((e) {
                        final isSelected = e.key == _selectedIconKey;
                        return InkWell(
                          onTap: () => setState(() => _selectedIconKey = e.key),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? Colors.white12 : Colors.black12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusS,
                              ),
                              border: Border.all(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withOpacity(isSelected ? 0.6 : 0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              e.value,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Goal'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
