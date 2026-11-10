import 'package:flutter/material.dart';

void main() {
  runApp(const BudgetTrackerApp());
}

/// Transaction Type: Income or Expense
enum TransactionType { income, expense }

/// Transaction Model
class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });
}

/// Budget State Manager using ChangeNotifier (Flutter State Management)
class BudgetManager extends ChangeNotifier {
  final List<TransactionItem> _transactions = [
    TransactionItem(
      id: '1',
      title: 'Monthly Salary',
      amount: 45000,
      type: TransactionType.income,
      category: 'Salary',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TransactionItem(
      id: '2',
      title: 'Apartment Rent',
      amount: 12000,
      type: TransactionType.expense,
      category: 'Housing',
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    TransactionItem(
      id: '3',
      title: 'Grocery Supplies',
      amount: 3500,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionItem(
      id: '4',
      title: 'Freelance Design',
      amount: 8000,
      type: TransactionType.income,
      category: 'Side Hustle',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get remainingBalance => totalIncome - totalExpense;

  double get savingsRatio => totalIncome > 0 ? (remainingBalance / totalIncome).clamp(-1.0, 1.0) : 0.0;

  String get financialStatus {
    if (totalIncome == 0 && totalExpense == 0) return 'No Activity Yet';
    if (remainingBalance < 0) return 'Deficit: Overspending! 🛑';
    if (savingsRatio >= 0.40) return 'Healthy Savings: Excellent! 🌟';
    if (savingsRatio >= 0.15) return 'Stable Budget: Good 👍';
    return 'Tight Budget: Watch Expenses ⚠️';
  }

  Color get statusColor {
    if (remainingBalance < 0) return Colors.red;
    if (savingsRatio >= 0.40) return Colors.green;
    if (savingsRatio >= 0.15) return Colors.blue;
    return Colors.amber.shade800;
  }

  void addTransaction(TransactionItem item) {
    _transactions.insert(0, item);
    notifyListeners(); // Notify UI to rebuild
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners(); // Notify UI to rebuild
  }
}

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Budget Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BudgetHomeScreen(),
    );
  }
}

class BudgetHomeScreen extends StatefulWidget {
  const BudgetHomeScreen({super.key});

  @override
  State<BudgetHomeScreen> createState() => _BudgetHomeScreenState();
}

class _BudgetHomeScreenState extends State<BudgetHomeScreen> {
  final BudgetManager _budgetManager = BudgetManager();

  @override
  void dispose() {
    _budgetManager.dispose();
    super.dispose();
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AddTransactionSheet(
        onAdd: (item) {
          _budgetManager.addTransaction(item);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder dynamically listens to ChangeNotifier state updates
    return ListenableBuilder(
      listenable: _budgetManager,
      builder: (context, _) {
        final totalIncome = _budgetManager.totalIncome;
        final totalExpense = _budgetManager.totalExpense;
        final balance = _budgetManager.remainingBalance;
        final statusText = _budgetManager.financialStatus;
        final statusColor = _budgetManager.statusColor;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Personal Budget Calculator',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.deepPurple.shade50,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Summary Banner Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Remaining Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Financial Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 26),

                    // Income vs Expense Breakdown Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BalanceStat(
                          label: 'Income',
                          amount: totalIncome,
                          color: Colors.greenAccent.shade400,
                          icon: Icons.arrow_downward,
                        ),
                        Container(width: 1, height: 36, color: Colors.white24),
                        _BalanceStat(
                          label: 'Expenses',
                          amount: totalExpense,
                          color: Colors.redAccent.shade100,
                          icon: Icons.arrow_upward,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Transaction List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_budgetManager.transactions.length} items',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              // Transactions ListView
              Expanded(
                child: _budgetManager.transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            const Text('No transactions yet. Add one below!'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _budgetManager.transactions.length,
                        itemBuilder: (context, index) {
                          final item = _budgetManager.transactions[index];
                          final isIncome = item.type == TransactionType.income;

                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              _budgetManager.deleteTransaction(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Removed "${item.title}"'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              elevation: 1.5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                                  child: Icon(
                                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isIncome ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${item.category} • ${item.date.day}/${item.date.month}/${item.date.year}'),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'}₹${item.amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ),
                          );
                          },
                        ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddTransactionModal,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Entry'),
          ),
        );
      },
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }
}

/// Modal Bottom Sheet for Adding Income or Expense
class AddTransactionSheet extends StatefulWidget {
  final Function(TransactionItem) onAdd;

  const AddTransactionSheet({super.key, required this.onAdd});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String _category = 'Food';

  final List<String> _expenseCategories = ['Food', 'Housing', 'Travel', 'Shopping', 'Bills', 'Other'];
  final List<String> _incomeCategories = ['Salary', 'Side Hustle', 'Investment', 'Gift', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid title and amount')),
      );
      return;
    }

    final item = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: _selectedType,
      category: _category,
      date: DateTime.now(),
    );

    widget.onAdd(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == TransactionType.expense ? _expenseCategories : _incomeCategories;
    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'New Transaction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          // Segmented Button: Income or Expense
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(
                value: TransactionType.expense,
                label: Text('Expense'),
                icon: Icon(Icons.arrow_upward),
              ),
              ButtonSegment(
                value: TransactionType.income,
                label: Text('Income'),
                icon: Icon(Icons.arrow_downward),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (set) {
              setState(() {
                _selectedType = set.first;
              });
            },
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Description / Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (₹)',
              border: OutlineInputBorder(),
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            key: ValueKey('$_selectedType-$_category'),
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _category = val);
            },
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Save Transaction', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
