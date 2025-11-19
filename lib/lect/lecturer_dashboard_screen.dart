import 'package:flutter/material.dart';
import 'model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl => dotenv.env['BASE_URL'] ?? '';
String get imageUrl => dotenv.env['IMAGE_URL'] ?? '';
const Color kPrimaryColor = Color(0xFF8A0E0E);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class LecturerDashboardScreen extends StatefulWidget {
  final int userId;
  const LecturerDashboardScreen({super.key, required this.userId});

  @override
  State<LecturerDashboardScreen> createState() =>
      _LecturerDashboardScreenState();
}

class _LecturerDashboardScreenState extends State<LecturerDashboardScreen> {
  List<Book> _booksWithRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookRequests();
  }

  Future<void> _fetchBookRequests() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/staff/getreturn'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        final pendingBooks = data
            .where((item) => item['status'] == 'pending')
            .toList();

        setState(() {
          _booksWithRequests = pendingBooks.map((b) {
            return Book(
              id: b['book_id'],
              title: b['book'],
              author: b['borrower'],
              imageUrl: (b['image'] == null || b['image'].toString().isEmpty)
                  ? '$baseUrl/uploads/default.png'
                  : '$baseUrl/uploads/${b['image']}',
              status: b['status'],
              borrowId: b['id'],
            );
          }).toList();

          isLoading = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✔️ Refreshed successfully!')),
      );
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _approve(int borrowId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    await http.put(
      Uri.parse('$baseUrl/approve/$borrowId'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({'approverId': widget.userId}),
    );

    _fetchBookRequests();
  }

  Future<void> _reject(int borrowId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    TextEditingController reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reject Reason"),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: "Enter reject reason...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, reasonController.text),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (reason == null || reason.isEmpty) return;

    await http.put(
      Uri.parse('$baseUrl/api/staff/reject/$borrowId'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({'reject_reason': reason, 'approverId': widget.userId}),
    );

    _fetchBookRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Book Borrow Request",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchBookRequests,
          ),
        ],
      ),

      // BODY
      body: RefreshIndicator(
        onRefresh: _fetchBookRequests,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _booksWithRequests.isEmpty
            ? const Center(child: Text("No pending requests"))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.50,
                ),
                itemCount: _booksWithRequests.length,
                itemBuilder: (context, index) {
                  final book = _booksWithRequests[index];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(
                              minHeight: 180, // เพิ่มความสูงขั้นต่ำให้การ์ด
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: 15 / 20,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      book.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.book, size: 40),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  book.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Borrower: ${book.author}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "Status: ${book.status}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ปุ่ม Approve / Reject
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => _approve(book.borrowId!),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => _reject(book.borrowId!),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
