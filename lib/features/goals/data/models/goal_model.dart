import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/goal.dart';

class GoalModel {
  const GoalModel({
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
  final String goalType;
  final double targetAmount;
  final DateTime targetDate;
  final List<String> linkedCategories;
  final double currentProgress;
  final bool autoCompute;
  final DateTime createdAt;
  final String? color;
  final String? icon;

  factory GoalModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      goalType: (data['goalType'] as String?) ?? 'saving',
      targetAmount: (data['targetAmount'] as num).toDouble(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      linkedCategories: List<String>.from(data['linkedCategories'] ?? []),
      currentProgress: (data['currentProgress'] as num? ?? 0).toDouble(),
      autoCompute: data['autoCompute'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      color: data['color'] as String?,
      icon: data['icon'] as String?,
    );
  }

  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      id: goal.id,
      userId: goal.userId,
      name: goal.name,
      description: goal.description,
      goalType: goal.goalType,
      targetAmount: goal.targetAmount,
      targetDate: goal.targetDate,
      linkedCategories: goal.linkedCategories,
      currentProgress: goal.currentProgress,
      autoCompute: goal.autoCompute,
      createdAt: goal.createdAt,
      color: goal.color,
      icon: goal.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'goalType': goalType,
      'targetAmount': targetAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'linkedCategories': linkedCategories,
      'currentProgress': currentProgress,
      'autoCompute': autoCompute,
      'createdAt': Timestamp.fromDate(createdAt),
      'color': color,
      'icon': icon,
    };
  }

  Goal toEntity() {
    return Goal(
      id: id,
      userId: userId,
      name: name,
      description: description,
      goalType: goalType,
      targetAmount: targetAmount,
      targetDate: targetDate,
      linkedCategories: linkedCategories,
      currentProgress: currentProgress,
      autoCompute: autoCompute,
      createdAt: createdAt,
      color: color,
      icon: icon,
    );
  }
}
