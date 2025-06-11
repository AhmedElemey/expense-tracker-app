import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';
import 'dashboard_screen.dart' show dashboardCategories;
import 'package:intl/intl.dart';

class PaginatedExpensesScreen extends ConsumerStatefulWidget {
  const PaginatedExpensesScreen({super.key});

  @override
  ConsumerState<PaginatedExpensesScreen> createState() => _PaginatedExpensesScreenState();
}

class _PaginatedExpensesScreenState extends ConsumerState<PaginatedExpensesScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedDate = 'All';
  final List<String> _dateFilters = [
    'All',
    'Today',
    'This week',
    'This month',
    'This year',
  ];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<ExpenseModel> _expenses = [];
  bool _initialLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchExpenses(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMore) {
      _fetchExpenses();
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedDate = filter;
      _currentPage = 0;
      _expenses.clear();
      _hasMore = true;
      _initialLoading = true;
      _error = null;
    });
    _fetchExpenses(reset: true);
  }

  Future<void> _fetchExpenses({bool reset = false}) async {
    if (_isLoadingMore || (!_hasMore && !reset)) return;
    setState(() {
      _isLoadingMore = true;
      if (reset) _initialLoading = true;
    });
    try {
      final repo = ref.read(expenseRepositoryProvider);
      final all = await repo.getExpenses(page: _currentPage, pageSize: _pageSize);
      final filtered = _filterExpenses(all);
      setState(() {
        if (reset) _expenses = [];
        _expenses.addAll(filtered);
        _hasMore = filtered.length == _pageSize;
        _currentPage++;
        _initialLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _initialLoading = false;
      });
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    if (_selectedDate == 'All') return expenses;
    if (_selectedDate == 'Today') {
      return expenses.where((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day).toList();
    } else if (_selectedDate == 'This week') {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      return expenses.where((e) => e.date.isAfter(weekStart.subtract(const Duration(days: 1))) && e.date.isBefore(weekEnd.add(const Duration(days: 1)))).toList();
    } else if (_selectedDate == 'This month') {
      return expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
    } else if (_selectedDate == 'This year') {
      return expenses.where((e) => e.date.year == now.year).toList();
    }
    return expenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'All Expenses',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: _dateFilters.map((filter) {
                final selected = filter == _selectedDate;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    backgroundColor: selected ? AppTheme.primaryColor : Colors.white,
                    label: Text(filter, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black)),
                    selected: selected,
                    onSelected: (_) => _onFilterChanged(filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _initialLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _expenses.isEmpty
                        ? const Center(child: Text('No expenses found.'))
                        : NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (!_isLoadingMore && _hasMore && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                                _fetchExpenses();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _expenses.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _expenses.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                final expense = _expenses[index];
                                final cat = dashboardCategories.firstWhere(
                                  (c) => c.label == expense.category,
                                  orElse: () => dashboardCategories[0],
                                );
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 12.0, left: 16, right: 16),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: cat.color,
                                      radius: 18,
                                      child: Icon(
                                        cat.icon,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                    subtitle: const Text("Manually", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                                    trailing: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '\$${expense.amount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          _formatExpenseDate(expense.date),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _formatExpenseDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today ${DateFormat('h a').format(date)}';
    } else {
      return DateFormat('MMM d, h a').format(date);
    }
  }
} 