import 'package:hive/hive.dart';
part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String currency;

  @HiveField(6)
  final String? receiptPath;

  @HiveField(7)
  final DateTime date;

  @HiveField(8)
  final double convertedAmount;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.description,
    required this.currency,
    this.receiptPath,
    required this.date,
    required this.convertedAmount,
  });
} 