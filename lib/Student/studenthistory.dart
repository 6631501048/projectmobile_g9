import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://192.168.49.1:3000';

class HistoryItem {
  final String book;
  final String borrowDate;
  final String returnDate;
  final String approver;
  final String receiver;
  final String status;
  final String image;

  HistoryItem({
    required this.book,
    required this.borrowDate,
    required this.returnDate,
    required this.approver,
    required this.receiver,
    required this.status,
    required this.image,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      book: json['book'] ?? '-',
      borrowDate: json['borrow_date'] ?? '-',
      returnDate: json['return_date'] ?? '-',
      approver: json['approver'] ?? '-',
      receiver: json['receiver'] ?? '-',
      status: json['status'] ?? 'Unknown',
      image: json['image'] ?? '',
    );
  }
}

class StudentHistory extends StatefulWidget {
  final int userId; // ✅ เพิ่มตัวนี้
  const StudentHistory({
    super.key,
    required this.userId,
  }); // ✅ รับค่ามาจากหน้า Home

  @override
  State<StudentHistory> createState() => _StudentHistoryState();
}

class _StudentHistoryState extends State<StudentHistory> {
  late Future<List<HistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory(
      widget.userId.toString(),
    ); // ✅ ใช้ userId จริง
  }

  Future<List<HistoryItem>> _fetchHistory(String studentId) async {
    final String apiUrl = "http://192.168.49.1:3000/api/history/$studentId";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((jsonItem) => HistoryItem.fromJson(jsonItem))
            .toList();
      } else {
        throw Exception(
          'Failed to load history (Status code: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'returned':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF8B1A1A),
      onRefresh: () async {
        setState(() {
          _historyFuture = _fetchHistory(
            widget.userId.toString(),
          ); // ✅ ใช้ userId จริง
        });
      },
      child: FutureBuilder<List<HistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B1A1A)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading data:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // ✅ ให้ดึงได้แม้ไม่มีข้อมูล
              children: const [
                SizedBox(height: 200),
                Center(
                  child: Text(
                    'You have no borrow history.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            );
          }

          final historyData = snapshot.data!;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: historyData.length,
            itemBuilder: (context, index) {
              final item = historyData[index];
              final statusColor = _getStatusColor(item.status);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                              item.book,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('Borrow: ${item.borrowDate}'),
                            Text('Return: ${item.returnDate}'),
                            Text('Approver: ${item.approver}'),
                            Text('Receiver: ${item.receiver}'),
                            const SizedBox(height: 6),
                            Text(
                              item.status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item.image.startsWith('http')
                              ? item.image
                              : '$baseUrl/uploads/${item.image}', // ✅ ถ้าไม่ใช่ http ให้ต่อ URL เอง
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
