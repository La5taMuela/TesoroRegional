// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavingsGoalModel _$SavingsGoalModelFromJson(Map<String, dynamic> json) =>
    SavingsGoalModel(
          id: json['id'] as String,
          userId: json['userId'] as String,
          title: json['title'] as String,
          description: json['description'] as String,
          targetAmount: (json['targetAmount'] as num).toDouble(),
          currentAmount: (json['currentAmount'] as num).toDouble(),
          targetDate: DateTime.parse(json['targetDate'] as String),
          createdAt: DateTime.parse(json['createdAt'] as String),
          isActive: json['isActive'] as bool,
          category: json['category'] as String,
    );

Map<String, dynamic> _$SavingsGoalModelToJson(SavingsGoalModel instance) =>
    <String, dynamic>{
          'id': instance.id,
          'userId': instance.userId,
          'title': instance.title,
          'description': instance.description,
          'targetAmount': instance.targetAmount,
          'currentAmount': instance.currentAmount,
          'targetDate': instance.targetDate.toIso8601String(),
          'createdAt': instance.createdAt.toIso8601String(),
          'isActive': instance.isActive,
          'category': instance.category,
    };
