import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Lecthistory(),
    );
  }
}

class Lecthistory extends StatelessWidget {
  const Lecthistory({super.key});

  final List<Map<String, String>> borrowHistory = const [
    {
      'book': 'Horror',
      'borrowDate': '5/10/2025',
      'returnDate': '12/10/2025',
      'borrower': 'Kwan',
      'status': 'Approved',
    },
    {
      'book': 'เรื่องเศร้าเล่มสีชมพู',
      'borrowDate': '10/10/2025',
      'returnDate': '17/10/2025',
      'borrower': 'Nat',
      'status': 'Rejected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(221, 179, 179, 179),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A1A),
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        margin: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              border: TableBorder.all(color: Colors.grey.shade400),
              columnSpacing: 30,
              headingRowColor: WidgetStateColor.resolveWith(
                (states) => const Color(0xFF8B1A1A),
              ),
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              columns: const [
                DataColumn(label: Text('Book')),
                DataColumn(label: Text('Borrower')), // ✅ เพิ่มคอลัมน์ชื่อผู้ยืม
                DataColumn(label: Text('Borrowing date')),
                DataColumn(label: Text('Date of return')),
                DataColumn(label: Text('Approval Status')),
              ],
              rows: borrowHistory.map((item) {
                Color statusColor;
                if (item['status'] == 'Approved') {
                  statusColor = Colors.green;
                } else if (item['status'] == 'Rejected') {
                  statusColor = Colors.red;
                } else {
                  statusColor = Colors.grey;
                }

                return DataRow(
                  cells: [
                    DataCell(Text(item['book']!)),
                    DataCell(Text(item['borrower']!)), // ✅ แสดงชื่อผู้ยืม
                    DataCell(Text(item['borrowDate']!)),
                    DataCell(Text(item['returnDate']!)),
                    DataCell(
                      Text(
                        item['status']!,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}