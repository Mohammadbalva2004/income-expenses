import 'package:Acountpro/model/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    bool isIncome = transaction.type == TransactionType.income;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isIncome ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.date),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${transaction.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction.type.name.toUpperCase(),
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) {
                  onEdit!();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}
