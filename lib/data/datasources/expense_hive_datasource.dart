import 'package:hive/hive.dart';
import '../models/expense_model.dart';

class ExpenseHiveDataSource {
  static const String boxName = 'expenses';
  late Box<ExpenseModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ExpenseModel>(boxName);
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _box.add(expense);
  }

  Future<List<ExpenseModel>> fetchExpenses({int page = 0, int pageSize = 10, String? filter}) async {
    final all = _box.values.toList();
    // TODO: Apply filter if needed
    final start = page * pageSize;
    final end = (start + pageSize) > all.length ? all.length : (start + pageSize);
    return all.sublist(start, end);
  }

  Future<void> deleteExpense(int key) async {
    await _box.delete(key);
  }

  List<ExpenseModel> getAll() => _box.values.toList();
} 