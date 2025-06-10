import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final expensesProvider = StateNotifierProvider<ExpensesNotifier, AsyncValue<List<ExpenseModel>>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return ExpensesNotifier(repository);
});

class ExpensesNotifier extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final ExpenseRepository _repository;
  static const int _pageSize = 10;
  int _currentPage = 0;
  bool _hasMore = true;

  ExpensesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
    }

    if (!_hasMore) return;

    try {
      if (_currentPage == 0) {
        state = const AsyncValue.loading();
      }

      final expenses = await _repository.getExpenses(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (expenses.length < _pageSize) {
        _hasMore = false;
      }

      if (_currentPage == 0) {
        state = AsyncValue.data(expenses);
      } else {
        state.whenData((currentExpenses) {
          state = AsyncValue.data([...currentExpenses, ...expenses]);
        });
      }

      _currentPage++;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _repository.addExpense(expense);
      await loadExpenses(refresh: true);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      await loadExpenses(refresh: true);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _repository.updateExpense(expense);
      await loadExpenses(refresh: true);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 