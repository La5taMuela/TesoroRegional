import 'package:json_annotation/json_annotation.dart';

part 'savings_goal_model.g.dart';

@JsonSerializable()
class SavingsGoalModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final bool isActive;
  final String category;

  const SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    required this.isActive,
    required this.category,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) => _$SavingsGoalModelFromJson(json);
  Map<String, dynamic> toJson() => _$SavingsGoalModelToJson(this);

  SavingsGoalModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isActive,
    String? category,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
    );
  }

  double get progressPercentage => (currentAmount / targetAmount) * 100;
  double get remainingAmount => targetAmount - currentAmount;
  bool get isCompleted => currentAmount >= targetAmount;
}
