import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';
import '../../core/theme.dart';
import 'package:intl/intl.dart';
import '../../data/services/currency_service.dart' as app_currency;
import 'package:currency_picker/currency_picker.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  String? _receiptPath;
  bool _isLoading = false;
  int _selectedCategoryIndex = 1;
  String _selectedCurrency = 'USD'; // Default to USD

  final List<CategoryData> _categories = [
    CategoryData('Groceries', Icons.shopping_cart, Color(0xFFE8ECFB)),
    CategoryData('Entertainment', Icons.local_play,Color(0xFFE8ECFB)),
    CategoryData('Gas', Icons.local_gas_station, Color(0xFFFDE8E8)),
    CategoryData('Shopping', Icons.shopping_bag, Color(0xFFFFF3E8)),
    CategoryData('News Paper', Icons.article, Color(0xFFFFF7E8)),
    CategoryData('Transport', Icons.directions_car, Color(0xFFE8E8FD)),
    CategoryData('Rent', Icons.home, Color(0xFFE8F8F5)),
    CategoryData('Add Category', Icons.add, Color(0xFFF7F8FA)),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptPath = pickedFile.path;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);
      // Fetch conversion
      final convertedAmount = await app_currency.CurrencyService.convertToUSD(amount, _selectedCurrency) ?? amount;
      final expense = ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _categories[_selectedCategoryIndex].label,
        amount: amount,
        category: _categories[_selectedCategoryIndex].label,
        description: '',
        currency: _selectedCurrency,
        receiptPath: _receiptPath,
        date: _selectedDate ?? DateTime.now(),
        convertedAmount: convertedAmount,
      );
      await ref.read(expensesProvider.notifier).addExpense(expense);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          'Add Expense',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),
              const SizedBox(height:8),
              const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Amount',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      showCurrencyPicker(
                        context: context,
                        showFlag: true,
                        showCurrencyName: true,
                        showCurrencyCode: true,
                        onSelect: (Currency currency) {
                          setState(() {
                            _selectedCurrency = currency.code;
                          });
                        },
                        favorite: ['USD', 'EGP', 'EUR', 'SAR'],
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_selectedCurrency, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 2),
                          const Icon(Icons.keyboard_arrow_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: _selectedDate == null ? DateFormat('MM/dd/yy').format(DateTime.now()) : DateFormat('MM/dd/yy').format(_selectedDate!),
                      hintStyle: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black,fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: const Icon(Icons.calendar_today, color: Colors.black,size: 18,),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Attach Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: AbsorbPointer(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: _receiptPath == null ? 'Upload image' : 'Image selected successfully',
                      hintStyle: TextStyle(color: _receiptPath == null ? Colors.grey : Colors.black,fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: const Icon(Icons.camera_alt_outlined, color: Colors.black,size: 18,),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildCategoryGrid(),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryIndex,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: List.generate(_categories.length - 1, (i) => i).map((i) {
        return DropdownMenuItem(
          value: i,
          child: Row(
            children: [
              // CircleAvatar(
              //   radius: 18,
              //   backgroundColor: _categories[i].color,
              //   child: Icon(_categories[i].icon,size: 16, color: i == _selectedCategoryIndex ? AppTheme.primaryColor : Colors.black),
              // ),
              
              Text(_categories[i].label),
            ],
          ),
        );
      }).toList(),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
      onChanged: (val) {
        if (val != null) setState(() => _selectedCategoryIndex = val);
      },
    );
  }

  Widget _buildCategoryGrid() {
    return SizedBox(
      height: 2 * 90.0, // 2 rows, each about 90px tall
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(_categories.length, (i) {
          final selected = i == _selectedCategoryIndex;
          return GestureDetector(
            onTap: i == 7 ? null : () => setState(() => _selectedCategoryIndex = i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: selected ? AppTheme.primaryColor : _categories[i].color,
                  child: Icon(
                    _categories[i].icon,
                    color: selected ? Colors.white : (i == 7 ? AppTheme.primaryColor : Colors.black),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _categories[i].label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? AppTheme.primaryColor : Colors.black,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                 
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class CategoryData {
  final String label;
  final IconData icon;
  final Color color;
  const CategoryData(this.label, this.icon, this.color);
} 