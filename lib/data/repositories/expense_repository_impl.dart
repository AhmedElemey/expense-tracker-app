import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';
import '../datasources/expense_hive_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseHiveDataSource dataSource;
  ExpenseRepositoryImpl(this.dataSource);

  @override
  Future<void> addExpense(ExpenseModel expense) => dataSource.addExpense(expense);

  @override
  Future<List<ExpenseModel>> fetchExpenses({int page = 0, int pageSize = 10, String? filter}) => dataSource.fetchExpenses(page: page, pageSize: pageSize, filter: filter);

  @override
  Future<void> deleteExpense(int id) => dataSource.deleteExpense(id);

  @override
  Future<double> getTotalIncome({String? filter}) async {
    final all = dataSource.getAll();
    return all.where((e) => e.amount > 0).fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Future<double> getTotalExpense({String? filter}) async {
    final all = dataSource.getAll();
    return all.where((e) => e.amount < 0).fold<double>(0.0, (sum, e) => sum + e.amount.abs());
  }

  @override
  Future<double> getTotalBalance({String? filter}) async {
    final all = dataSource.getAll();
    return all.fold<double>(0.0, (sum, e) => sum + e.amount);
  }
} 