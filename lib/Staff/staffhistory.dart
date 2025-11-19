import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectmobile_g9/Login-Regis/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

String get baseUrl => dotenv.env['BASE_URL'] ?? '';
String get imageUrl => dotenv.env['IMAGE_URL'] ?? '';

class StaffHistory extends StatefulWidget {
  const StaffHistory({super.key});

  @override
  State<StaffHistory> createState() => _StaffHistoryState();
}

class _StaffHistoryState extends State<StaffHistory> {
  List<dynamic> borrowHistory = [];
  bool isLoading = true;

  Future<void> fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/staff/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        setState(() {
          borrowHistory = json.decode(res.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load history (${res.statusCode})');
      }
    } catch (e) {
      print('❌ Error fetching history: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

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

        // ✅ Burger menu (☰)
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (ctx) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔄 Refresh
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.blue),
                      title: const Text('Refresh History'),
                      onTap: () {
                        Navigator.pop(ctx);
                        fetchHistory();
                      },
                    ),

                    const Divider(height: 1),

                    // 🚪 Logout
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Navigator.pop(ctx); // ปิดเมนู
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text(
                              'Are you sure you want to log out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop(); // ปิด dialog
                                  Future.delayed(
                                    const Duration(milliseconds: 150),
                                    () {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LoginPage(), // ✅ กลับหน้า Login
                                        ),
                                        (route) =>
                                            false, // ล้างทุกหน้าออกจาก stack
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // 🔄 ปุ่ม refresh ขวาบน (เหมือนเดิม)
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B1A1A)),
              )
            : borrowHistory.isEmpty
            ? const Center(
                child: Text(
                  'No history found',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
            : Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  itemCount: borrowHistory.length,
                  itemBuilder: (context, index) {
                    final item = borrowHistory[index];
                    final status = (item['status'] ?? '-')
                        .toString()
                        .toLowerCase();

                    // ✅ สีสถานะ
                    final Color statusColor;
                    if (status == 'approved' ||
                        status == 'borrowed' ||
                        status == 'returned') {
                      statusColor = Colors.green;
                    } else if (status == 'pending') {
                      statusColor = Colors.orange;
                    } else {
                      statusColor = Colors.red;
                    }

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
                            // ข้อมูลหนังสือ
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
                                  Text(
                                    "Borrow date: ${item['borrowDate'] ?? '-'}",
                                  ),
                                  Text(
                                    "Return date: ${item['returnDate'] ?? '-'}",
                                  ),
                                  Text("Borrower: ${item['borrower'] ?? '-'}"),
                                  Row(
                                    children: [
                                      const Text("Status: "),
                                      Text(
                                        item['status'] ?? '-',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text("Approver: ${item['approver'] ?? '-'}"),
                                  Text("Receiver: ${item['receiver'] ?? '-'}"),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // รูปภาพหนังสือ
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 90,
                                height: 120,
                                child: Image.network(
                                  '$baseUrl/uploads/${item['image']}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 36,
                                        color: Colors.black38,
                                      ),
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
      ),
    );
  }
}
