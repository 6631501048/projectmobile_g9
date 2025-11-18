import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl => dotenv.env['BASE_URL'] ?? '';
String get imageUrl => dotenv.env['IMAGE_URL'] ?? '';

class Lecthistory extends StatefulWidget {
  final int userId;
  const Lecthistory({Key? key, required this.userId}) : super(key: key);

  @override
  State<Lecthistory> createState() => _LecthistoryState();
}

class _LecthistoryState extends State<Lecthistory> {
  List<dynamic> borrowHistory = [];
  bool isLoading = true;

  // ✅ ดึงข้อมูลจาก API
  Future<void> fetchHistory() async {
    setState(() => isLoading = true); // แสดงโหลดก่อนรีเฟรช
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/staff/history'));
      if (res.statusCode == 200) {
        setState(() {
          borrowHistory = json.decode(res.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print('❌ Error fetching history: $e');
      setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'borrowed':
      case 'returned':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistory(); // ✅ ดึงข้อมูลเมื่อเปิดหน้า
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A1A),
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,

        // ✅ ปุ่มรีเฟรช
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () async {
              await fetchHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History refreshed successfully!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),

      // ✅ ใช้ RefreshIndicator เพื่อรีเฟรชหน้า
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : borrowHistory.isEmpty
          ? const Center(
              child: Text(
                'No history available',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchHistory, // ดึงข้อมูลใหม่เมื่อดึงลง
              color: const Color(0xFF8B1A1A),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                itemCount: borrowHistory.length,
                itemBuilder: (context, index) {
                  final item = borrowHistory[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
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
                                Text("Borrower: ${item['borrower'] ?? '-'}"),
                                Text(
                                  "Borrow date: ${item['borrowDate'] ?? '-'}",
                                ),
                                Text(
                                  "Return date: ${item['returnDate'] ?? '-'}",
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['status'] ?? '-',
                                  style: TextStyle(
                                    color: getStatusColor(item['status'] ?? ''),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if ((item['status'] ?? '').toLowerCase() ==
                                    'rejected')
                                  Text(
                                    "Reject reason: ${item['reject_reason'] ?? '-'}",
                                    style: TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              '${baseUrl}/uploads/${item['image'] ?? 'default.png'}',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.image_not_supported,
                                    size: 60,
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
    );
  }
}
