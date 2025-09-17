import 'package:equatable/equatable.dart';

class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.userId,
    required this.name,
    required this.goalType,
    required this.targetAmount,
    required this.targetDate,
    required this.linkedCategories,
    required this.currentProgress,
    required this.autoCompute,
    required this.createdAt,
    this.description,
    this.color,
    this.icon,
  });

  final String id;
  final String userId;
  final String name;
  final String? description;
  // 'saving' | 'budget'
  final String goalType;
  final double targetAmount;
  final DateTime targetDate;
  final List<String> linkedCategories;
  final double currentProgress;
  final bool autoCompute;
  final DateTime createdAt;
  final String? color;
  final String? icon;

  double get progressPercentage => targetAmount > 0
      ? (currentProgress / targetAmount * 100).clamp(0, 100)
      : 0;

  bool get isCompleted => currentProgress >= targetAmount;

  Duration get timeRemaining {
    final now = DateTime.now();
    return targetDate.isAfter(now) ? targetDate.difference(now) : Duration.zero;
  }

  double get requiredDailyProgress {
    final daysRemaining = timeRemaining.inDays;
    if (daysRemaining <= 0) return 0;
    final remainingAmount = targetAmount - currentProgress;
    return remainingAmount > 0 ? remainingAmount / daysRemaining : 0;
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? goalType,
    double? targetAmount,
    DateTime? targetDate,
    List<String>? linkedCategories,
    double? currentProgress,
    bool? autoCompute,
    DateTime? createdAt,
    String? color,
    String? icon,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      goalType: goalType ?? this.goalType,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      linkedCategories: linkedCategories ?? this.linkedCategories,
      currentProgress: currentProgress ?? this.currentProgress,
      autoCompute: autoCompute ?? this.autoCompute,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    goalType,
    targetAmount,
    targetDate,
    linkedCategories,
    currentProgress,
    autoCompute,
    createdAt,
    color,
    icon,
  ];
}
