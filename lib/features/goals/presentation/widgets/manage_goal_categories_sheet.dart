import 'package:flutter/material.dart';
import 'package:omni/features/categories/data/categories_repository.dart';

class ManageGoalCategoriesSheet extends StatefulWidget {
  final List<String> initialSelectedIds;
  final String? goalType; // 'saving' | 'budget' (optional filter)
  const ManageGoalCategoriesSheet({
    super.key,
    required this.initialSelectedIds,
    this.goalType,
  });

  @override
  State<ManageGoalCategoriesSheet> createState() =>
      _ManageGoalCategoriesSheetState();
}

class _ManageGoalCategoriesSheetState extends State<ManageGoalCategoriesSheet> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelectedIds};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(
                      0.2,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Link categories',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: CategoriesRepository().watchAll(),
                  builder: (context, snapshot) {
                    var cats = snapshot.data ?? const [];
                    final t = widget.goalType;
                    if (t == 'saving') {
                      cats = cats.where((c) => c['type'] == 'income').toList();
                    } else if (t == 'budget') {
                      cats = cats.where((c) => c['type'] == 'expense').toList();
                    }
                    if (cats.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No categories found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: cats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final c = cats[index];
                        final id = c['id'] as String;
                        final name = (c['name'] as String?) ?? '';
                        final emoji = (c['emoji'] as String?) ?? '';
                        final type = (c['type'] as String?) ?? '';
                        final selected = _selected.contains(id);
                        return InkWell(
                          onTap: () => setState(() {
                            if (selected) {
                              _selected.remove(id);
                            } else {
                              _selected.add(id);
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  selected ? 0.6 : 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.06),
                                  ),
                                  child: Text(
                                    type,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(selected ? 0.9 : 0.5),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_selected.toList()),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
