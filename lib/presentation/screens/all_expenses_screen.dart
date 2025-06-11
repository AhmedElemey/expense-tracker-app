import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';
import 'package:intl/intl.dart';
import 'dashboard_screen.dart' show dashboardCategories;

class AllExpensesScreen extends ConsumerStatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  ConsumerState<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends ConsumerState<AllExpensesScreen> {
  String _selectedCategory = 'All';
  String _selectedDate = 'All';

  final List<String> _categories = [
    'All',
    'Food',
    'Transportation',
    'Shopping',
    'Bills',
    'Entertainment',
    'Other',
  ];

  final List<String> _dateFilters = [
    'All',
    'Today',
    'This Week',
    'This Month',
  ];

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    var filtered = expenses;
    if (_selectedCategory != 'All') {
      filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }
    if (_selectedDate != 'All') {
      final now = DateTime.now();
      if (_selectedDate == 'Today') {
        filtered = filtered.where((e) =>
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day
        ).toList();
      } else if (_selectedDate == 'This Week') {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        filtered = filtered.where((e) =>
          e.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          e.date.isBefore(weekEnd.add(const Duration(days: 1)))
        ).toList();
      } else if (_selectedDate == 'This Month') {
        filtered = filtered.where((e) =>
          e.date.year == now.year &&
          e.date.month == now.month
        ).toList();
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final selected = cat == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(cat),
                              selected: selected,
                              onSelected: (_) {
                                setState(() => _selectedCategory = cat);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedDate,
                    items: _dateFilters.map((date) => DropdownMenuItem(
                      value: date,
                      child: Text(date),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDate = val);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildExpenseList(_filterExpenses(expensesAsync.value ?? [])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final cat = dashboardCategories.firstWhere(
          (c) => c.label == expense.category,
          orElse: () => dashboardCategories[0],
        );
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          shadowColor: Colors.black26,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: cat.color,
              radius: 18,
              child: Icon(
                size: 20,
                cat.icon,
                color: Colors.black,
              ),
            ),
            title: Text(expense.category, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            subtitle: Text("Manually", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$ ${expense.convertedAmount.toStringAsFixed(2)}',
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
            onTap: () {
              // TODO: Implement expense details
            },
          ),
        );
      },
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