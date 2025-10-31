import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StudentHistory(),
  ));
}

class StudentHistory extends StatelessWidget {
  const StudentHistory({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  final List<Map<String, String>> historyData = const [
    {
      'book': 'เรือนแสงสีแดง',
      'borrowDate': '5/10/2025',
      'returnDate': '12/10/2025',
      'approver': '-',
      'receiver': '-',
      'status': 'Pending',
      'image': 'assets/images/Picture/1.jpg'
    },
    {
      'book': 'Ready Player One',
      'borrowDate': '7/10/2025',
      'returnDate': '14/10/2025',
      'approver': 'Ms. Emily Johnson',
      'receiver': 'Mr. David Wong',
      'status': 'Approved',
      'image': 'assets/images/Picture/ready.jpg'
    },
    {
      'book': 'แปดขุนเขา',
      'borrowDate': '10/10/2025',
      'returnDate': '17/10/2025',
      'approver': '-',
      'receiver': '-',
      'status': 'Rejected',
      'image': 'assets/images/Picture/2.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A1A),
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          final item = historyData[index];
          final statusColor = _getStatusColor(item['status']!);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['book']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 6),
                        Text('Borrow: ${item['borrowDate']}'),
                        Text('Return: ${item['returnDate']}'),
                        Text('Approver: ${item['approver']}'),
                        Text('Receiver: ${item['receiver']}'),
                        const SizedBox(height: 6),
                        Text(
                          item['status']!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      item['image']!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          color: const Color(0xFF8B1A1A),
          height: 65,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                NavItem(icon: Icons.home, label: 'Home'),
                NavItem(icon: Icons.add_box, label: 'My Request'),
                NavItem(icon: Icons.history, label: 'History'),
                NavItem(icon: Icons.person, label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const NavItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }
}
