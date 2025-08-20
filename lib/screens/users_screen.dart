import 'package:Acountpro/model/transaction.dart';
import 'package:Acountpro/model/user.dart';

import 'package:flutter/material.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/transaction_tile.dart';
import '../database/database_helper.dart';
import '../utils/pdf_generator.dart';

class UsersScreen extends StatefulWidget {
  final User user;

  const UsersScreen({super.key, required this.user});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Transaction> userTransactions = [];
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);

    try {
      final transactions = await _databaseHelper.getTransactionsByUser(
        widget.user.id!,
      );
      final income = await _databaseHelper.getUserIncome(widget.user.id!);
      final expense = await _databaseHelper.getUserExpense(widget.user.id!);

      setState(() {
        userTransactions = transactions;
        totalIncome = income;
        totalExpense = expense;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  String getInitials(String name) {
    List<String> parts = name.split(" ");
    if (parts.length > 1) {
      return parts[0][0] + parts[1][0];
    }
    return parts[0][0];
  }

  List<Transaction> filteredTransactions() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) return userTransactions.reversed.toList();
    return userTransactions
        .where((t) => t.description.toLowerCase().contains(query))
        .toList()
        .reversed
        .toList();
  }

  void _showAddTransactionSheet(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    TransactionType transactionType = TransactionType.income;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Add Transaction",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Income"),
                        selected: transactionType == TransactionType.income,
                        selectedColor: Colors.green.shade100,
                        onSelected: (val) {
                          setModalState(
                            () => transactionType = TransactionType.income,
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("Expense"),
                        selected: transactionType == TransactionType.expense,
                        selectedColor: Colors.red.shade100,
                        onSelected: (val) {
                          setModalState(
                            () => transactionType = TransactionType.expense,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: "Note (optional)",
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (amountController.text.isEmpty) return;

                            final newTransaction = Transaction(
                              userId: widget.user.id!,
                              amount: double.parse(amountController.text),
                              description:
                                  noteController.text.isEmpty
                                      ? "No description"
                                      : noteController.text,
                              type: transactionType,
                              date: DateTime.now(),
                            );

                            try {
                              await _databaseHelper.insertTransaction(
                                newTransaction,
                              );
                              await _loadTransactions(); // Reload transactions

                              Navigator.pop(context);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Transaction added successfully!',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error adding transaction: $e',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Add Transaction"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTransactionSheet(
    BuildContext context,
    Transaction transaction,
  ) {
    final TextEditingController amountController = TextEditingController(
      text: transaction.amount.toString(),
    );
    final TextEditingController noteController = TextEditingController(
      text: transaction.description,
    );
    TransactionType transactionType = transaction.type;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Edit Transaction",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Income"),
                        selected: transactionType == TransactionType.income,
                        selectedColor: Colors.green.shade100,
                        onSelected: (val) {
                          setModalState(
                            () => transactionType = TransactionType.income,
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("Expense"),
                        selected: transactionType == TransactionType.expense,
                        selectedColor: Colors.red.shade100,
                        onSelected: (val) {
                          setModalState(
                            () => transactionType = TransactionType.expense,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: "Note (optional)",
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (amountController.text.isEmpty) return;

                            final updatedTransaction = Transaction(
                              id: transaction.id,
                              userId: transaction.userId,
                              amount: double.parse(amountController.text),
                              description:
                                  noteController.text.isEmpty
                                      ? "No description"
                                      : noteController.text,
                              type: transactionType,
                              date: transaction.date, // Keep original date
                            );

                            try {
                              await _databaseHelper.updateTransaction(
                                updatedTransaction,
                              );
                              await _loadTransactions();

                              Navigator.pop(context);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Transaction updated successfully!',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error updating transaction: $e',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Update Transaction"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: Text(
              'Are you sure you want to delete this transaction?\n\n'
              '${transaction.description}\n'
              '₹${transaction.amount.toStringAsFixed(2)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _databaseHelper.deleteTransaction(transaction.id!);
                    await _loadTransactions();

                    Navigator.pop(context);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction deleted successfully!'),
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting transaction: $e'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _exportUserToPDF() async {
    try {
      final filePath = await PDFGenerator.generateUserTransactionsPDF(
        user: widget.user,
        transactions: userTransactions,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved successfully!:'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double totalBalance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pop(
                context,
                true,
              ), // Return true to indicate data may have changed
        ),
        title: Column(
          children: [
            Text(
              "Welcome, ${widget.user.name}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Your personal financial dashboard",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadTransactions,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Export PDF',
            onPressed: _exportUserToPDF,
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Text(
              getInitials(widget.user.name),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Dashboard cards
            DashboardCard(
              icon: Icons.trending_up,
              color: Colors.green,
              title: "Total Incomes",
              amount: "₹${totalIncome.toStringAsFixed(0)}",
            ),
            DashboardCard(
              icon: Icons.trending_down,
              color: Colors.red,
              title: "Total Expenses",
              amount: "₹${totalExpense.toStringAsFixed(0)}",
            ),
            DashboardCard(
              icon: Icons.account_balance_wallet,
              color: Colors.blue,
              title: "Total Balance",
              amount: "₹${totalBalance.toStringAsFixed(0)}",
            ),

            const SizedBox(height: 20),

            // Add button + Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => _showAddTransactionSheet(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              "Add Transaction",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Transactions...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Transactions List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Transactions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("${filteredTransactions().length} transactions found"),
                  const SizedBox(height: 10),

                  if (filteredTransactions().isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No transactions yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "Add your first transaction to get started",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions().length,
                      itemBuilder: (context, index) {
                        var txn = filteredTransactions()[index];
                        return TransactionTile(
                          transaction: txn,
                          onEdit: () => _showEditTransactionSheet(context, txn),
                          onDelete: () => _showDeleteConfirmation(context, txn),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
