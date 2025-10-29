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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,

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
                    columnSpacing: 25,
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
                      DataColumn(label: Text('Receiver')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: [
                      _buildRow('Horror', '5/10/2025', '12/10/2025', 'Pending', this),
                      _buildRow('Fantasy', '7/10/2025', '14/10/2025', 'Approved', this),
                      _buildRow('Romance', '10/10/2025', '17/10/2025', 'Rejected', this),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างแถวของ DataTable พร้อมจัดการเครื่องหมายและสีสถานะ
  static DataRow _buildRow(
      String book, String borrowDate, String returnDate, String status, StudentHistory state) {
    final approver =
        (status == 'Approved') ? _getApproverName(book) : '-';
    final receiver =
        (status == 'Approved') ? _getReceiverName(book) : '-';
    final color = state._getStatusColor(status);

    return DataRow(cells: [
      DataCell(Text(book)),
      DataCell(Text(borrowDate)),
      DataCell(Text(returnDate)),
      DataCell(Text(approver)),
      DataCell(Text(receiver)),
      DataCell(Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      )),
    ]);
  }

  static String _getApproverName(String book) {
    switch (book) {
      case 'Horror':
        return 'Mr. John Smith';
      case 'Fantasy':
        return 'Ms. Emily Johnson';
      case 'Romance':
        return 'Mr. Robert Brown';
      default:
        return '-';
    }
  }

  static String _getReceiverName(String book) {
    switch (book) {
      case 'Horror':
        return 'Ms. Anna Lee';
      case 'Fantasy':
        return 'Mr. David Wong';
      case 'Romance':
        return 'Ms. Sarah Kim';
      default:
        return '-';
    }
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