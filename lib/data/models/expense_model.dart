import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel {
  final String id;
  final String userId;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final bool isRecurring;
  final String? notes;

  const ExpenseModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.isRecurring,
    this.notes,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => _$ExpenseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    bool? isRecurring,
    String? notes,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      notes: notes ?? this.notes,
    );
  }
}
