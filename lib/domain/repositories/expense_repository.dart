import '../../data/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(ExpenseModel expense);
  Future<List<ExpenseModel>> fetchExpenses({int page = 0, int pageSize = 10, String? filter});
  Future<void> deleteExpense(int id);
  Future<double> getTotalIncome({String? filter});
  Future<double> getTotalExpense({String? filter});
  Future<double> getTotalBalance({String? filter});
} 