import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StudentHistory(),
  ));
}

class StudentHistory extends StatelessWidget {
  const StudentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // กันข้อความล้นขอบจอ
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A1A),
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: DataTable(
                    columnSpacing: 30,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF8B1A1A)),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    columns: const [
                      DataColumn(label: Text('Book')),
                      DataColumn(label: Text('Borrowing date')),
                      DataColumn(label: Text('Date of return')),
                      DataColumn(label: Text('Approver')),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('Horror')),
                        DataCell(Text('5/10/2025')),
                        DataCell(Text('12/10/2025')),
                        DataCell(Text('Pending')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Fantasy')),
                        DataCell(Text('7/10/2025')),
                        DataCell(Text('14/10/2025')),
                        DataCell(Text('Approved')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Romance')),
                        DataCell(Text('10/10/2025')),
                        DataCell(Text('17/10/2025')),
                        DataCell(Text('Rejected')),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          color: const Color(0xFF8B1A1A),
          height: 65, // ปรับให้พอดี ไม่ชนขอบ
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
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }
}
