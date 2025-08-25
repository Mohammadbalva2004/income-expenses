import 'package:flutter/material.dart';
import 'package:multi_user_expense_app/model/user.dart';
import '../utils/pdf_generator.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/user_card.dart';
import '../database/database_helper.dart';
import 'users_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _editNameController = TextEditingController();
  final _editMobileController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<User> users = [];
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  bool isLoading = true;

  Map<int, double> userIncomes = {};
  Map<int, double> userExpenses = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final loadedUsers = await _databaseHelper.getAllUsers();
      final income = await _databaseHelper.getTotalIncome();
      final expense = await _databaseHelper.getTotalExpense();

      // per-user income/expense
      Map<int, double> incomes = {};
      Map<int, double> expenses = {};
      for (var u in loadedUsers) {
        incomes[u.id!] = await _databaseHelper.getUserIncome(u.id!);
        expenses[u.id!] = await _databaseHelper.getUserExpense(u.id!);
      }

      setState(() {
        users = loadedUsers;
        totalIncome = income;
        totalExpense = expense;
        userIncomes = incomes;
        userExpenses = expenses;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  List<User> get filteredUsers {
    if (_searchController.text.isEmpty) return users;
    return users
        .where(
          (user) =>
              user.name.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ) ||
              user.mobile.contains(_searchController.text),
        )
        .toList();
  }

  double get totalBalance => totalIncome - totalExpense;

  Future<void> _exportToPDF() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Generating PDF...'),
          ],
        ),
      ),
    );

    try {
      final filePath = await PDFGenerator.generateDashboardPDF(
        users: users,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        userIncomes: userIncomes,
        userExpenses: userExpenses,
      );

      Navigator.pop(context); // Close loading dialog

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved successfully!\nLocation: $filePath'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddUserDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Add New User",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Mobile Number (optional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) return;

                final newUser = User(
                  name: _nameController.text.trim(),
                  mobile: _mobileController.text.trim(),
                  joinDate: DateTime.now(),
                  balance: 0,
                  transactions: 0,
                );

                try {
                  await _databaseHelper.insertUser(newUser);
                  await _loadData();

                  _nameController.clear();
                  _mobileController.clear();
                  Navigator.pop(context);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User added successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding user: $e')),
                    );
                  }
                }
              },
              child: const Text("Add User"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditUserDialog(User user) async {
    _editNameController.text = user.name;
    _editMobileController.text = user.mobile;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Edit User",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _editNameController,
                  decoration: InputDecoration(
                    labelText: "Full Name *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _editMobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Mobile Number (optional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (_editNameController.text.trim().isEmpty) return;

                final updatedUser = user.copyWith(
                  name: _editNameController.text.trim(),
                  mobile: _editMobileController.text.trim(),
                );

                try {
                  await _databaseHelper.updateUser(updatedUser);
                  await _loadData();

                  Navigator.pop(context);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User updated successfully!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating user: $e')),
                    );
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteUserDialog(User user) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Delete User",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Are you sure you want to delete ${user.name}?"),
              const SizedBox(height: 8),
              const Text(
                "This will also delete all transactions associated with this user.",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                try {
                  await _databaseHelper.deleteUserWithTransactions(user.id!);
                  await _loadData();

                  Navigator.pop(context);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'User and transactions deleted successfully!',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting user: $e')),
                    );
                  }
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading dashboard...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Multi User Income-Expenses",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Export Dashboard PDF',
            onPressed: _exportToPDF,
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            DashboardCard(
              icon: Icons.people,
              color: Colors.purple,
              title: "Total Users",
              amount: users.length.toString(),
            ),
            DashboardCard(
              icon: Icons.trending_up,
              color: Colors.green,
              title: "Total Income",
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
              color: totalBalance >= 0 ? Colors.blue : Colors.orange,
              title: "Net Balance",
              amount: "₹${totalBalance.toStringAsFixed(0)}",
            ),

            const SizedBox(height: 20),

            // Add New User Button + Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _showAddUserDialog,
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
                              "Add User",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
                        hintText: 'Search users...',
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

            // All Users List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "All Users",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Manage user accounts and generate reports"),
                        ],
                      ),
                      if (users.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${filteredUsers.length} users",
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (filteredUsers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              users.isEmpty ? "No users yet" : "No users found",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              users.isEmpty
                                  ? "Add your first user to get started"
                                  : "Try adjusting your search",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filteredUsers
                        .map(
                          (user) => UserCard(
                            user: user,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UsersScreen(user: user),
                                ),
                              );
                              if (result == true) {
                                _loadData();
                              }
                            },
                            onEdit: () => _showEditUserDialog(user),
                            onDelete: () => _showDeleteUserDialog(user),
                          ),
                        )
                        .toList(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _editNameController.dispose();
    _editMobileController.dispose();
    super.dispose();
  }
}
