import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';
import 'package:intl/intl.dart';
import 'add_expense_screen.dart' show CategoryData;


final List<CategoryData> dashboardCategories = [
  CategoryData('Groceries', Icons.shopping_cart, Color(0xFFE8ECFB)),
  CategoryData('Entertainment', Icons.local_play, Color(0xFFE8ECFB)),
  CategoryData('Gas', Icons.local_gas_station, Color(0xFFFDE8E8)),
  CategoryData('Shopping', Icons.shopping_bag, Color(0xFFFFF3E8)),
  CategoryData('News Paper', Icons.article, Color(0xFFFFF7E8)),
  CategoryData('Transport', Icons.directions_car, Color(0xFFE8E8FD)),
  CategoryData('Rent', Icons.home, Color(0xFFE8F8F5)),
];

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scrollController = ScrollController();
  int _selectedIndex = 0;
  final String _selectedFilter = 'All';
  String _selectedDate = 'This month';
  final List<String> _dateFilters = [
    'Today',
    'This week',
    'This month',
    'This year',
  ];
  final List<Widget> _pages = [
    const SizedBox.shrink(), // Placeholder for dashboard content
    Scaffold(backgroundColor: Colors.white),
    Scaffold(backgroundColor: Colors.white),
    Scaffold(backgroundColor: Colors.white),
    Scaffold(backgroundColor: Colors.white),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(expensesProvider.notifier).loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    Widget mainContent;
    if (_selectedIndex == 0) {
      mainContent = Column(
        children: [
          // Top blue background with rounded bottom corners
          SizedBox(
            height: 330,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B5AFB), Color(0xFF4F8CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
               
              ),
               child: Column(
                children: [
                  const SizedBox(height: 35),
                  _buildHeader(),
                ],
              ),
                ),
                 Positioned(
                  top: 110,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical:15),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: const Color(0xFF496EF3),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Balance',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.8)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '\$242,548.00', // Replace with dynamic value if needed
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:  [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.white.withOpacity(0.2),
                                          child:  Icon(Icons.arrow_downward, color: Colors.white, size: 16),
                                        ),
                                        SizedBox(width: 5),
                                        Text('Income', style: TextStyle(color: Colors.white, fontSize: 14)),
                                      ],
                                    ),
                                    SizedBox(height: 3),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text('\$410,840.00', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                 Row(mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.white.withOpacity(0.2),
                                          child:  Icon(Icons.arrow_downward, color: Colors.white, size: 16),
                                        ),
                                        SizedBox(width: 5),
                                          Text('Expenses', style: TextStyle(color: Colors.white, fontSize: 14)),

                                   ],
                                 ),
                                 SizedBox(height: 3),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text('\$41,884.00', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            
                
                // Balance card styled as in the design
               
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Expenses',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    // fontFamily: 'Poppins', // Uncomment if using Poppins
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const PaginatedExpensesScreen(),
                    //   ),
                    // );
                  },
                  child: Text(
                    'see all',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: expensesAsync.when(
              data: (expenses) => _buildExpenseList(expenses),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      );
    } else if (_selectedIndex == 2) {
      // Add Expense navigates to add expense screen
      Future.microtask(() => Navigator.pushNamed(context, '/add-expense'));
      mainContent = const SizedBox.shrink();
    } else {
      mainContent = _pages[_selectedIndex] ?? const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Color(0xFFFDFDFD),
      body: mainContent,
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: _selectedIndex == 0 ? Color(0xFF3B5AFB) : Color(0xFF8F9BB3)),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            IconButton(
              icon: Icon(Icons.bar_chart, color: _selectedIndex == 1 ? Color(0xFF3B5AFB) : Color(0xFF8F9BB3)),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, '/add-expense');
                setState(() => _selectedIndex = 0);
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF3B5AFB),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
            IconButton(
              icon: Icon(Icons.account_balance_wallet_outlined, color: _selectedIndex == 3 ? Color(0xFF3B5AFB) : Color(0xFF8F9BB3)),
              onPressed: () => setState(() => _selectedIndex = 3),
            ),
            IconButton(
              icon: Icon(Icons.person_outline, color: _selectedIndex == 4 ? Color(0xFF3B5AFB) : Color(0xFF8F9BB3)),
              onPressed: () async {
                await Navigator.pushNamed(context, '/profile');
                setState(() => _selectedIndex = 0);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.network(
                'https://images.media.io/imgsharpen/home/swiper-img1-after.png',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 32, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Greeting and name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 3),
                const Text(
                  'Shihab Rahman',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Date filter dropdown
          Container(
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDate,
                items: _dateFilters.map((date) => DropdownMenuItem(
                  value: date,
                  child: Text(date),
                )).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDate = val);
                },
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildExpenseList(List<ExpenseModel> expenses) {
    // Filter by date
    final now = DateTime.now();
    List<ExpenseModel> filtered = expenses;
    if (_selectedDate == 'Today') {
      filtered = expenses.where((e) =>
        e.date.year == now.year &&
        e.date.month == now.month &&
        e.date.day == now.day
      ).toList();
    } else if (_selectedDate == 'This week') {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      filtered = expenses.where((e) =>
        e.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        e.date.isBefore(weekEnd.add(const Duration(days: 1)))
      ).toList();
    } else if (_selectedDate == 'This month') {
      filtered = expenses.where((e) =>
        e.date.year == now.year &&
        e.date.month == now.month
      ).toList();
    } else if (_selectedDate == 'This year') {
      filtered = expenses.where((e) =>
        e.date.year == now.year
      ).toList();
    }
    if (filtered.isEmpty) {
      return const Center(
        child: Text('No expenses yet. Add your first expense!'),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final expense = filtered[index];
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
            subtitle: Text("Manually", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12,color: Colors.grey)),
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