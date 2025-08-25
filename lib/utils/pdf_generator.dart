
// // import 'dart:io';
// // import 'package:multi_user_expense_app/model/transaction.dart';
// // import 'package:multi_user_expense_app/model/user.dart';

// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pw;
// // import 'package:path_provider/path_provider.dart';
// // import 'package:intl/intl.dart';
// // import 'package:open_file/open_file.dart';
// // import 'package:permission_handler/permission_handler.dart';

// // class PDFGenerator {
// //   static Future<Directory?> _getDownloadsDirectory() async {
// //     if (Platform.isAndroid) {
// //       var status = await Permission.storage.status;

// //       if (!status.isGranted) {
// //         status = await Permission.storage.request();
// //         if (!status.isGranted) {
// //           var manageStatus = await Permission.manageExternalStorage.status;
// //           if (!manageStatus.isGranted) {
// //             manageStatus = await Permission.manageExternalStorage.request();
// //             if (!manageStatus.isGranted) {
// //               final appDir = await getExternalStorageDirectory();
// //               if (appDir != null) {
// //                 final downloadsDir = Directory('${appDir.path}/PDFs');
// //                 if (!await downloadsDir.exists()) {
// //                   await downloadsDir.create(recursive: true);
// //                 }
// //                 return downloadsDir;
// //               }
// //               return null;
// //             }
// //           }
// //         }
// //       }

// //       List<String> possiblePaths = [
// //         '/storage/emulated/0/Download',
// //         '/storage/emulated/0/Downloads',
// //         '/sdcard/Download',
// //         '/sdcard/Downloads',
// //       ];

// //       for (String path in possiblePaths) {
// //         Directory directory = Directory(path);
// //         if (await directory.exists()) {
// //           try {
// //             final testFile = File('${directory.path}/.test_write');
// //             await testFile.writeAsString('test');
// //             await testFile.delete();
// //             return directory;
// //           } catch (e) {
// //             continue;
// //           }
// //         }
// //       }

// //       final appDir = await getExternalStorageDirectory();
// //       if (appDir != null) {
// //         final downloadsDir = Directory('${appDir.path}/PDFs');
// //         if (!await downloadsDir.exists()) {
// //           await downloadsDir.create(recursive: true);
// //         }
// //         return downloadsDir;
// //       }
// //     }

// //     return await getApplicationDocumentsDirectory();
// //   }

// //   static Future<String> generateDashboardPDF({
// //     required List<User> users,
// //     required double totalIncome,
// //     required double totalExpense,
// //   }) async {
// //     try {
// //       final pdf = pw.Document();
// //       final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

// //       pdf.addPage(
// //         pw.MultiPage(
// //           pageFormat: PdfPageFormat.a4,
// //           margin: const pw.EdgeInsets.all(32),
// //           build: (pw.Context context) {
// //             return [
// //               pw.Container(
// //                 alignment: pw.Alignment.center,
// //                 child: pw.Column(
// //                   children: [
// //                     pw.Text(
// //                       'Multi User Income-Expenses Dashboard',
// //                       style: pw.TextStyle(
// //                         fontSize: 24,
// //                         fontWeight: pw.FontWeight.bold,
// //                       ),
// //                     ),
// //                     pw.SizedBox(height: 8),
// //                     pw.Text(
// //                       'Generated on ${dateFormat.format(DateTime.now())}',
// //                       style: const pw.TextStyle(
// //                         fontSize: 12,
// //                         color: PdfColors.grey,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               pw.SizedBox(height: 30),

// //               pw.Container(
// //                 padding: const pw.EdgeInsets.all(16),
// //                 decoration: pw.BoxDecoration(
// //                   border: pw.Border.all(color: PdfColors.grey300),
// //                   borderRadius: pw.BorderRadius.circular(8),
// //                 ),
// //                 child: pw.Row(
// //                   mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
// //                   children: [
// //                     _buildSummaryCard('Total Users', users.length.toString()),
// //                     _buildSummaryCard('Total Income', totalIncome.toString()),
// //                     _buildSummaryCard('Total Expense', totalExpense.toString()),
// //                     _buildSummaryCard(
// //                       'Balance',
// //                       (totalIncome - totalExpense).toString(),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               pw.SizedBox(height: 30),

// //               pw.Text(
// //                 'Users List',
// //                 style: pw.TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: pw.FontWeight.bold,
// //                 ),
// //               ),
// //               pw.SizedBox(height: 16),

// //               pw.Table(
// //                 border: pw.TableBorder.all(color: PdfColors.grey300),
// //                 columnWidths: {
// //                   0: const pw.FlexColumnWidth(3),
// //                   1: const pw.FlexColumnWidth(2),
// //                   2: const pw.FlexColumnWidth(2),
// //                   3: const pw.FlexColumnWidth(2),
// //                   4: const pw.FlexColumnWidth(2),
// //                 },
// //                 children: [
// //                   pw.TableRow(
// //                     decoration: const pw.BoxDecoration(
// //                       color: PdfColors.grey100,
// //                     ),
// //                     children: [
// //                       _buildTableCell('Name', isHeader: true),
// //                       _buildTableCell('Mobile', isHeader: true),
// //                       _buildTableCell('Join Date', isHeader: true),
// //                       _buildTableCell('Balance', isHeader: true),
// //                       _buildTableCell('Transactions', isHeader: true),
// //                     ],
// //                   ),
// //                   ...users.map(
// //                     (user) => pw.TableRow(
// //                       children: [
// //                         _buildTableCell(user.name),
// //                         _buildTableCell(
// //                           user.mobile.isEmpty ? 'N/A' : user.mobile,
// //                         ),
// //                         _buildTableCell(
// //                           DateFormat('dd/MM/yyyy').format(user.joinDate),
// //                         ),
// //                         _buildTableCell(user.balance.toString()),
// //                         _buildTableCell(user.transactions.toString()),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ];
// //           },
// //         ),
// //       );

// //       final directory = await _getDownloadsDirectory();
// //       if (directory == null) {
// //         throw Exception('Unable to access storage. Please check permissions.');
// //       }

// //       final fileName =
// //           'Dashboard_Report_${DateFormat('yyyyMMdd_hhmmss_a').format(DateTime.now())}.pdf';
// //       final file = File('${directory.path}/$fileName');

// //       await file.writeAsBytes(await pdf.save());

// //       try {
// //         await OpenFile.open(file.path);
// //       } catch (e) {
// //         print('PDF saved but could not open automatically: $e');
// //       }

// //       return file.path;
// //     } catch (e) {
// //       throw Exception('Failed to generate PDF: $e');
// //     }
// //   }

// //   static Future<String> generateUserTransactionsPDF({
// //     required User user,
// //     required List<Transaction> transactions,
// //     required double totalIncome,
// //     required double totalExpense,
// //   }) async {
// //     try {
// //       final pdf = pw.Document();
// //       final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

// //       pdf.addPage(
// //         pw.MultiPage(
// //           pageFormat: PdfPageFormat.a4,
// //           margin: const pw.EdgeInsets.all(32),
// //           build: (pw.Context context) {
// //             return [
// //               pw.Container(
// //                 alignment: pw.Alignment.center,
// //                 child: pw.Column(
// //                   children: [
// //                     pw.Text(
// //                       'Transaction Report',
// //                       style: pw.TextStyle(
// //                         fontSize: 24,
// //                         fontWeight: pw.FontWeight.bold,
// //                       ),
// //                     ),
// //                     pw.SizedBox(height: 8),
// //                     pw.Text(
// //                       'User: ${user.name}',
// //                       style: pw.TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: pw.FontWeight.bold,
// //                       ),
// //                     ),
// //                     if (user.mobile.isNotEmpty)
// //                       pw.Text(
// //                         'Mobile: ${user.mobile}',
// //                         style: const pw.TextStyle(fontSize: 12),
// //                       ),
// //                     pw.SizedBox(height: 4),
// //                     pw.Text(
// //                       'Generated on ${dateFormat.format(DateTime.now())}',
// //                       style: const pw.TextStyle(
// //                         fontSize: 12,
// //                         color: PdfColors.grey,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               pw.SizedBox(height: 30),

// //               pw.Container(
// //                 padding: const pw.EdgeInsets.all(16),
// //                 decoration: pw.BoxDecoration(
// //                   border: pw.Border.all(color: PdfColors.grey300),
// //                   borderRadius: pw.BorderRadius.circular(8),
// //                 ),
// //                 child: pw.Row(
// //                   mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
// //                   children: [
// //                     _buildSummaryCard('Total Income', totalIncome.toString()),
// //                     _buildSummaryCard('Total Expense', totalExpense.toString()),
// //                     _buildSummaryCard(
// //                       'Balance',
// //                       (totalIncome - totalExpense).toString(),
// //                     ),
// //                     _buildSummaryCard(
// //                       'Transactions',
// //                       transactions.length.toString(),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               pw.SizedBox(height: 30),

// //               pw.Text(
// //                 'Transaction History',
// //                 style: pw.TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: pw.FontWeight.bold,
// //                 ),
// //               ),
// //               pw.SizedBox(height: 16),

// //               if (transactions.isEmpty)
// //                 pw.Container(
// //                   alignment: pw.Alignment.center,
// //                   padding: const pw.EdgeInsets.all(40),
// //                   child: pw.Text(
// //                     'No transactions found',
// //                     style: const pw.TextStyle(
// //                       fontSize: 16,
// //                       color: PdfColors.grey,
// //                     ),
// //                   ),
// //                 )
// //               else
// //                 pw.Table(
// //                   border: pw.TableBorder.all(color: PdfColors.grey300),
// //                   columnWidths: {
// //                     0: const pw.FlexColumnWidth(3),
// //                     1: const pw.FlexColumnWidth(2),
// //                     2: const pw.FlexColumnWidth(2),
// //                     3: const pw.FlexColumnWidth(3),
// //                   },
// //                   children: [
// //                     pw.TableRow(
// //                       decoration: const pw.BoxDecoration(
// //                         color: PdfColors.grey100,
// //                       ),
// //                       children: [
// //                         _buildTableCell('Description', isHeader: true),
// //                         _buildTableCell('Type', isHeader: true),
// //                         _buildTableCell('Amount', isHeader: true),
// //                         _buildTableCell('Date', isHeader: true),
// //                       ],
// //                     ),
// //                     ...transactions.reversed
// //                         .take(50)
// //                         .map(
// //                           (transaction) => pw.TableRow(
// //                             children: [
// //                               _buildTableCell(transaction.description),
// //                               _buildTableCell(
// //                                 transaction.type == TransactionType.income
// //                                     ? 'Income'
// //                                     : 'Expense',
// //                                 color:
// //                                     transaction.type == TransactionType.income
// //                                         ? PdfColors.green
// //                                         : PdfColors.red,
// //                               ),
// //                               _buildTableCell(
// //                                 transaction.amount.toString(),
// //                                 color:
// //                                     transaction.type == TransactionType.income
// //                                         ? PdfColors.green
// //                                         : PdfColors.red,
// //                               ),
// //                               _buildTableCell(
// //                                 dateFormat.format(transaction.date),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                   ],
// //                 ),

// //               if (transactions.length > 50)
// //                 pw.Padding(
// //                   padding: const pw.EdgeInsets.only(top: 16),
// //                   child: pw.Text(
// //                     'Note: Only the latest 50 transactions are shown.',
// //                     style: const pw.TextStyle(
// //                       fontSize: 10,
// //                       color: PdfColors.grey,
// //                     ),
// //                   ),
// //                 ),
// //             ];
// //           },
// //         ),
// //       );

// //       final directory = await _getDownloadsDirectory();
// //       if (directory == null) {
// //         throw Exception('Unable to access storage. Please check permissions.');
// //       }

// //       final fileName =
// //           '${user.name}_Transactions_${DateFormat('yyyyMMdd_hhmmss_a').format(DateTime.now())}.pdf';
// //       final file = File('${directory.path}/$fileName');

// //       await file.writeAsBytes(await pdf.save());

// //       try {
// //         await OpenFile.open(file.path);
// //       } catch (e) {
// //         print('PDF saved but could not open automatically: $e');
// //       }

// //       return file.path;
// //     } catch (e) {
// //       throw Exception('Failed to generate PDF: $e');
// //     }
// //   }

// //   static pw.Widget _buildSummaryCard(String title, String value) {
// //     return pw.Column(
// //       children: [
// //         pw.Text(
// //           title,
// //           style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
// //         ),
// //         pw.SizedBox(height: 4),
// //         pw.Text(
// //           value,
// //           style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
// //         ),
// //       ],
// //     );
// //   }

// //   static pw.Widget _buildTableCell(
// //     String text, {
// //     bool isHeader = false,
// //     PdfColor? color,
// //   }) {
// //     return pw.Container(
// //       padding: const pw.EdgeInsets.all(8),
// //       child: pw.Text(
// //         text,
// //         style: pw.TextStyle(
// //           fontSize: isHeader ? 12 : 10,
// //           fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
// //           color: color ?? PdfColors.black,
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'dart:io';
// import 'package:multi_user_expense_app/model/transaction.dart';
// import 'package:multi_user_expense_app/model/user.dart';

// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';
// import 'package:open_file/open_file.dart';
// import 'package:permission_handler/permission_handler.dart';

// class PDFGenerator {
//   static Future<Directory?> _getDownloadsDirectory() async {
//     if (Platform.isAndroid) {
//       var status = await Permission.storage.status;

//       if (!status.isGranted) {
//         status = await Permission.storage.request();
//         if (!status.isGranted) {
//           var manageStatus = await Permission.manageExternalStorage.status;
//           if (!manageStatus.isGranted) {
//             manageStatus = await Permission.manageExternalStorage.request();
//             if (!manageStatus.isGranted) {
//               final appDir = await getExternalStorageDirectory();
//               if (appDir != null) {
//                 final downloadsDir = Directory('${appDir.path}/PDFs');
//                 if (!await downloadsDir.exists()) {
//                   await downloadsDir.create(recursive: true);
//                 }
//                 return downloadsDir;
//               }
//               return null;
//             }
//           }
//         }
//       }

//       List<String> possiblePaths = [
//         '/storage/emulated/0/Download',
//         '/storage/emulated/0/Downloads',
//         '/sdcard/Download',
//         '/sdcard/Downloads',
//       ];

//       for (String path in possiblePaths) {
//         Directory directory = Directory(path);
//         if (await directory.exists()) {
//           try {
//             final testFile = File('${directory.path}/.test_write');
//             await testFile.writeAsString('test');
//             await testFile.delete();
//             return directory;
//           } catch (e) {
//             continue;
//           }
//         }
//       }

//       final appDir = await getExternalStorageDirectory();
//       if (appDir != null) {
//         final downloadsDir = Directory('${appDir.path}/PDFs');
//         if (!await downloadsDir.exists()) {
//           await downloadsDir.create(recursive: true);
//         }
//         return downloadsDir;
//       }
//     }

//     return await getApplicationDocumentsDirectory();
//   }

//   static Future<String> generateDashboardPDF({
//     required List<User> users,
//     required double totalIncome,
//     required double totalExpense,
//     required Map<int, double> userIncomes,
//     required Map<int, double> userExpenses,
//   }) async {
//     try {
//       final pdf = pw.Document();
//       final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

//       pdf.addPage(
//         pw.MultiPage(
//           pageFormat: PdfPageFormat.a4,
//           margin: const pw.EdgeInsets.all(32),
//           build: (pw.Context context) {
//             return [
//               pw.Container(
//                 alignment: pw.Alignment.center,
//                 child: pw.Column(
//                   children: [
//                     pw.Text(
//                       'Multi User Income-Expenses Dashboard',
//                       style: pw.TextStyle(
//                         fontSize: 24,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                     pw.SizedBox(height: 8),
//                     pw.Text(
//                       'Generated on ${dateFormat.format(DateTime.now())}',
//                       style: const pw.TextStyle(
//                         fontSize: 12,
//                         color: PdfColors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 30),

//               pw.Container(
//                 padding: const pw.EdgeInsets.all(16),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey300),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildSummaryCard('Total Users', users.length.toString()),
//                     _buildSummaryCard('Total Income', totalIncome.toString()),
//                     _buildSummaryCard('Total Expense', totalExpense.toString()),
//                     _buildSummaryCard(
//                       'Balance',
//                       (totalIncome - totalExpense).toString(),
//                     ),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 30),

//               pw.Text(
//                 'Users List',
//                 style: pw.TextStyle(
//                   fontSize: 18,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.SizedBox(height: 16),

//               pw.Table(
//                 border: pw.TableBorder.all(color: PdfColors.grey300),
//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(3),
//                   1: const pw.FlexColumnWidth(2),
//                   2: const pw.FlexColumnWidth(2),
//                   3: const pw.FlexColumnWidth(2),
//                   4: const pw.FlexColumnWidth(2),
//                   5: const pw.FlexColumnWidth(2),
//                   6: const pw.FlexColumnWidth(2),
//                 },
//                 children: [
//                   pw.TableRow(
//                     decoration: const pw.BoxDecoration(
//                       color: PdfColors.grey100,
//                     ),
//                     children: [
//                       _buildTableCell('Name', isHeader: true),
//                       _buildTableCell('Mobile', isHeader: true),
//                       _buildTableCell('Join Date', isHeader: true),
//                       _buildTableCell('Income', isHeader: true),
//                       _buildTableCell('Expense', isHeader: true),
//                       _buildTableCell('Balance', isHeader: true),
//                       _buildTableCell('Transactions', isHeader: true),
//                     ],
//                   ),
//                   ...users.map(
//                     (user) => pw.TableRow(
//                       children: [
//                         _buildTableCell(user.name),
//                         _buildTableCell(
//                           user.mobile.isEmpty ? 'N/A' : user.mobile,
//                         ),
//                         _buildTableCell(
//                           DateFormat('dd/MM/yyyy').format(user.joinDate),
//                         ),
//                         _buildTableCell(
//                           (userIncomes[user.id!] ?? 0).toString(),
//                         ),
//                         _buildTableCell(
//                           (userExpenses[user.id!] ?? 0).toString(),
//                         ),
//                         _buildTableCell(user.balance.toString()),
//                         _buildTableCell(user.transactions.toString()),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ];
//           },
//         ),
//       );

//       final directory = await _getDownloadsDirectory();
//       if (directory == null) {
//         throw Exception('Unable to access storage. Please check permissions.');
//       }

//       final fileName =
//           'Dashboard_Report_${DateFormat('yyyyMMdd_hhmmss_a').format(DateTime.now())}.pdf';
//       final file = File('${directory.path}/$fileName');

//       await file.writeAsBytes(await pdf.save());

//       try {
//         await OpenFile.open(file.path);
//       } catch (e) {
//         print('PDF saved but could not open automatically: $e');
//       }

//       return file.path;
//     } catch (e) {
//       throw Exception('Failed to generate PDF: $e');
//     }
//   }

//   // Transaction PDF function remains same as before ...

//   static pw.Widget _buildSummaryCard(String title, String value) {
//     return pw.Column(
//       children: [
//         pw.Text(
//           title,
//           style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
//         ),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           value,
//           style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
//         ),
//       ],
//     );
//   }

//   static pw.Widget _buildTableCell(
//     String text, {
//     bool isHeader = false,
//     PdfColor? color,
//   }) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: isHeader ? 12 : 10,
//           fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//           color: color ?? PdfColors.black,
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:multi_user_expense_app/model/transaction.dart';
import 'package:multi_user_expense_app/model/user.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class PDFGenerator {
  // ------------------- STORAGE ACCESS -------------------
  static Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;

      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          var manageStatus = await Permission.manageExternalStorage.status;
          if (!manageStatus.isGranted) {
            manageStatus = await Permission.manageExternalStorage.request();
            if (!manageStatus.isGranted) {
              final appDir = await getExternalStorageDirectory();
              if (appDir != null) {
                final downloadsDir = Directory('${appDir.path}/PDFs');
                if (!await downloadsDir.exists()) {
                  await downloadsDir.create(recursive: true);
                }
                return downloadsDir;
              }
              return null;
            }
          }
        }
      }

      List<String> possiblePaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/sdcard/Download',
        '/sdcard/Downloads',
      ];

      for (String path in possiblePaths) {
        Directory directory = Directory(path);
        if (await directory.exists()) {
          try {
            final testFile = File('${directory.path}/.test_write');
            await testFile.writeAsString('test');
            await testFile.delete();
            return directory;
          } catch (_) {
            continue;
          }
        }
      }

      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        final downloadsDir = Directory('${appDir.path}/PDFs');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return downloadsDir;
      }
    }

    return await getApplicationDocumentsDirectory();
  }

  // ------------------- DASHBOARD PDF -------------------
  static Future<String> generateDashboardPDF({
    required List<User> users,
    required double totalIncome,
    required double totalExpense,
    required Map<int, double> userIncomes,
    required Map<int, double> userExpenses,
  }) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // HEADER
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Multi User Income-Expenses Dashboard',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Generated on ${dateFormat.format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // SUMMARY
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryCard('Total Users', users.length.toString()),
                    _buildSummaryCard('Total Income', totalIncome.toString()),
                    _buildSummaryCard('Total Expense', totalExpense.toString()),
                    _buildSummaryCard(
                      'Balance',
                      (totalIncome - totalExpense).toString(),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // USERS LIST
              pw.Text(
                'Users List',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2),
                  6: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                    ),
                    children: [
                      _buildTableCell('Name', isHeader: true),
                      _buildTableCell('Mobile', isHeader: true),
                      _buildTableCell('Join Date', isHeader: true),
                      _buildTableCell('Income', isHeader: true),
                      _buildTableCell('Expense', isHeader: true),
                      _buildTableCell('Balance', isHeader: true),
                      _buildTableCell('Transactions', isHeader: true),
                    ],
                  ),
                  ...users.map(
                    (user) => pw.TableRow(
                      children: [
                        _buildTableCell(user.name),
                        _buildTableCell(
                          user.mobile.isEmpty ? 'N/A' : user.mobile,
                        ),
                        _buildTableCell(
                          DateFormat('dd/MM/yyyy').format(user.joinDate),
                        ),
                        _buildTableCell(
                          (userIncomes[user.id!] ?? 0).toString(),
                        ),
                        _buildTableCell(
                          (userExpenses[user.id!] ?? 0).toString(),
                        ),
                        _buildTableCell(user.balance.toString()),
                        _buildTableCell(user.transactions.toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      final directory = await _getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Unable to access storage. Please check permissions.');
      }

      final fileName =
          'Dashboard_Report_${DateFormat('yyyyMMdd_hhmmss_a').format(DateTime.now())}.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);

      return file.path;
    } catch (e) {
      throw Exception('Failed to generate Dashboard PDF: $e');
    }
  }

  // ------------------- USER TRANSACTIONS PDF -------------------
  static Future<String> generateUserTransactionsPDF({
    required User user,
    required List<Transaction> transactions,
    required double totalIncome,
    required double totalExpense,
  }) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // HEADER
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Transaction Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'User: ${user.name}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (user.mobile.isNotEmpty)
                      pw.Text(
                        'Mobile: ${user.mobile}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on ${dateFormat.format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // SUMMARY
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryCard('Total Income', totalIncome.toString()),
                    _buildSummaryCard('Total Expense', totalExpense.toString()),
                    _buildSummaryCard(
                      'Balance',
                      (totalIncome - totalExpense).toString(),
                    ),
                    _buildSummaryCard(
                      'Transactions',
                      transactions.length.toString(),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // TRANSACTION HISTORY
              pw.Text(
                'Transaction History',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),

              if (transactions.isEmpty)
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Text(
                    'No transactions found',
                    style: const pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.grey,
                    ),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(3),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        _buildTableCell('Description', isHeader: true),
                        _buildTableCell('Type', isHeader: true),
                        _buildTableCell('Amount', isHeader: true),
                        _buildTableCell('Date', isHeader: true),
                      ],
                    ),
                    ...transactions.reversed.take(50).map(
                      (transaction) => pw.TableRow(
                        children: [
                          _buildTableCell(transaction.description),
                          _buildTableCell(
                            transaction.type == TransactionType.income
                                ? 'Income'
                                : 'Expense',
                            color: transaction.type == TransactionType.income
                                ? PdfColors.green
                                : PdfColors.red,
                          ),
                          _buildTableCell(
                            transaction.amount.toString(),
                            color: transaction.type == TransactionType.income
                                ? PdfColors.green
                                : PdfColors.red,
                          ),
                          _buildTableCell(dateFormat.format(transaction.date)),
                        ],
                      ),
                    ),
                  ],
                ),

              if (transactions.length > 50)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 16),
                  child: pw.Text(
                    'Note: Only the latest 50 transactions are shown.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
            ];
          },
        ),
      );

      final directory = await _getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Unable to access storage. Please check permissions.');
      }

      final fileName =
          '${user.name}_Transactions_${DateFormat('yyyyMMdd_hhmmss_a').format(DateTime.now())}.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);

      return file.path;
    } catch (e) {
      throw Exception('Failed to generate User Transactions PDF: $e');
    }
  }

  // ------------------- HELPERS -------------------
  static pw.Widget _buildSummaryCard(String title, String value) {
    return pw.Column(
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }
}
