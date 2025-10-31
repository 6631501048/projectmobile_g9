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
      'book': 'DUNE (MOVIE TIE IN)',
      'borrowDate': '5/10/2025',
      'returnDate': '12/10/2025',
      'borrower': 'Kwan',
      'status': 'Approve',
      'approver': 'Nataporn',
      'receiver': 'Beam',
      'image': 'assets/images/Picture/1.jpg',
    },
    {
      'book': 'Ready Player One',
      'borrowDate': '7/10/2025',
      'returnDate': '14/10/2025',
      'borrower': 'Mint',
      'status': 'Reject',
      'approver': 'Fah',
      'receiver': '',
      'image': 'assets/images/Picture/ready.jpg',
    },
    {
      'book': 'Little Red Hood',
      'borrowDate': '9/10/2025',
      'returnDate': '16/10/2025',
      'borrower': 'June',
      'status': 'Approve',
      'approver': 'Beam',
      'receiver': 'Nataporn',
      'image': 'assets/images/Picture/redhood.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A1A),
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: borrowHistory.length,
          itemBuilder: (context, index) {
            final item = borrowHistory[index];
            final status = item['status'] ?? '-';
            final receiver = (status == 'Reject' || (item['receiver'] ?? '').isEmpty)
                ? '-'
                : item['receiver']!;
            final statusColor = status == 'Approve' ? Colors.green : Colors.red;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['book'] ?? '-',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Borrowing date: ${item['borrowDate'] ?? '-'}"),
                          Text("Return date: ${item['returnDate'] ?? '-'}"),
                          Text("Borrower: ${item['borrower'] ?? '-'}"),
                          Row(
                            children: [
                              const Text("Status: "),
                              Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text("Approver: ${item['approver'] ?? '-'}"),
                          Text("Receiver: $receiver"),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Right image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 90,
                        height: 120,
                        child: Image.asset(
                          item['image'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported, size: 36, color: Colors.black38),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
