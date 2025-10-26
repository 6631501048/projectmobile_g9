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
      home: StaffHistory(), 
    );
  }
}

class StaffHistory extends StatelessWidget {
  const StaffHistory({super.key});

  final List<Map<String, String>> borrowHistory = const [
    {
      'book': 'Horror',
      'borrowDate': '5/10/2025',
      'returnDate': '12/10/2025',
      'borrower': 'Kwan',
      'approver': 'Nataporn',
    },
    {
      'book': 'Fantasy',
      'borrowDate': '7/10/2025',
      'returnDate': '14/10/2025',
      'borrower': 'Mint',
      'approver': 'Fah',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A1A),
        title: const Text(
          'History/Staff',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
  color: Colors.white,
  margin: const EdgeInsets.all(10),
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SingleChildScrollView( // ✅ เพิ่ม scroll แนวตั้งด้วย
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: 30, // ✅ เพิ่มระยะห่างระหว่างคอลัมน์
        headingRowColor: WidgetStateColor.resolveWith(
          (states) => const Color(0xFF8B1A1A),
        ),
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        columns: const [
          DataColumn(label: Text('Book')),
          DataColumn(label: Text('Borrowing date')),
          DataColumn(label: Text('Date of return')),
          DataColumn(label: Text('Borrower')),
          DataColumn(label: Text('Approver')),
        ],
        rows: borrowHistory.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item['book']!)),
              DataCell(Text(item['borrowDate']!)),
              DataCell(Text(item['returnDate']!)),
              DataCell(Text(item['borrower']!)),
              DataCell(Text(item['approver']!)),
            ],
          );
        }).toList(),
      ),
    ),
  ),
),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF8B1A1A),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Manage'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
