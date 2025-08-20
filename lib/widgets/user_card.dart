import 'package:Acountpro/model/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.shade200,
              child: Text(
                user.name.isNotEmpty ? user.name[0] : "?",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user.mobile.isNotEmpty)
                    Text(
                      user.mobile,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Joined: ${DateFormat('dd/MM/yyyy').format(user.joinDate)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${user.balance.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${user.transactions} transactions",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        height: 35,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "Dashboard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
