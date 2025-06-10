import 'package:hive/hive.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  static const String _boxName = 'expenses';

  Future<Box<ExpenseModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<ExpenseModel>(_boxName);
    }
    return Hive.box<ExpenseModel>(_boxName);
  }

  Future<List<ExpenseModel>> getExpenses({
    int page = 0,
    int pageSize = 10,
  }) async {
    final box = await _getBox();
    final start = page * pageSize;
    final end = start + pageSize;
    return box.values.skip(start).take(pageSize).toList();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final box = await _getBox();
    await box.put(expense.id, expense);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final box = await _getBox();
    await box.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    final box = await _getBox();
    return box.values.where((expense) => expense.category == category).toList();
  }

  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final box = await _getBox();
    return box.values
        .where((expense) =>
            expense.date.isAfter(start) && expense.date.isBefore(end))
        .toList();
  }

  Future<double> getTotalBalance() async {
    final box = await _getBox();
    final expenses = box.values.toList();
    return expenses.isEmpty ? 0.0 : expenses.map((e) => e.convertedAmount).reduce((a, b) => a + b);
  }

  Future<double> getTotalIncome() async {
    final box = await _getBox();
    final expenses = box.values.where((expense) => expense.amount > 0).toList();
    return expenses.isEmpty ? 0.0 : expenses.map((e) => e.convertedAmount).reduce((a, b) => a + b);
  }

  Future<double> getTotalExpenses() async {
    final box = await _getBox();
    final expenses = box.values.where((expense) => expense.amount < 0).toList();
    return expenses.isEmpty ? 0.0 : expenses.map((e) => e.convertedAmount).reduce((a, b) => a + b);
  }
} 