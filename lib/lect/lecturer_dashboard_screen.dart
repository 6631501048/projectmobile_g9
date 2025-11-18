import 'package:flutter/material.dart';
import 'model.dart';
import 'pedingApprove.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl => dotenv.env['BASE_URL'] ?? '';
String get imageUrl => dotenv.env['IMAGE_URL'] ?? '';
const Color kPrimaryColor = Color(0xFF8A0E0E);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class LecturerDashboardScreen extends StatefulWidget {
  final int userId;
  const LecturerDashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _LecturerDashboardScreenState createState() =>
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
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/staff/getreturn'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final pendingBooks =
            data.where((item) => item['status'] == 'pending').toList();

        setState(() {
          _booksWithRequests = pendingBooks
              .map(
                (b) => Book(
                  id: b['id'],
                  title: b['book'],
                  author: b['borrower'],
                  imageUrl: b['image'],
                  status: b['status'],
                ),
              )
              .toList();
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Refreshed successfully!')),
      );
    } catch (e) {
      print('❌ Error fetching pending requests: $e');
      setState(() => isLoading = false);
    }
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
            onPressed: _fetchBookRequests, // ✅ ปุ่มรีเฟรช
            tooltip: "Refresh",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBookRequests, // ✅ ปัดลงเพื่อรีเฟรช
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _booksWithRequests.isEmpty
                ? const Center(child: Text("No pending requests"))
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _booksWithRequests.length,
                    itemBuilder: (context, index) {
                      final book = _booksWithRequests[index];
                      return InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PendingApprovalScreen(book: book, userId: widget.userId),
                            ),
                          );
                          _fetchBookRequests(); // โหลดใหม่ตอนกลับ
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  book.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.book,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  book.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
