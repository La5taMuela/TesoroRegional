// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      isRecurring: json['isRecurring'] as bool,
      notes: json['notes'] as String?,
);

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
          'id': instance.id,
          'userId': instance.userId,
          'description': instance.description,
          'amount': instance.amount,
          'category': instance.category,
          'date': instance.date.toIso8601String(),
          'isRecurring': instance.isRecurring,
          'notes': instance.notes,
    };
