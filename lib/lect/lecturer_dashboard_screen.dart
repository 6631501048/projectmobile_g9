import 'package:flutter/material.dart';
import 'model.dart';
import 'pedingApprove.dart';

const Color kPrimaryColor = Color(0xFF8A0E0E);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class LecturerDashboardScreen extends StatefulWidget {
  const LecturerDashboardScreen({Key? key}) : super(key: key);

  @override
  _LecturerDashboardScreenState createState() =>
      _LecturerDashboardScreenState();
}

class _LecturerDashboardScreenState extends State<LecturerDashboardScreen> {
  List<Book> _booksWithRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchBookRequests();
  }

  void _fetchBookRequests() {
    final pendingBookIds = mockRequests
        .where((req) => req.status == 'pending')
        .map((req) => req.bookId)
        .toSet();

    setState(() {
      _booksWithRequests = mockBooks
          .where((book) => pendingBookIds.contains(book.id))
          .toList();
    });
  }

  int _getPendingRequestCount(String bookId) {
    return mockRequests
        .where((req) => req.bookId == bookId && req.status == 'pending')
        .length;
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
        elevation: 4,
      ),
      body: _booksWithRequests.isEmpty
          ? Center(
              child: Text(
                "No pending book requests.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.65,
              ),
              itemCount: _booksWithRequests.length,
              itemBuilder: (context, index) {
                final book = _booksWithRequests[index];
                final requestCount = _getPendingRequestCount(book.id);
                return _buildBookGridItem(context, book, requestCount);
              },
            ),
    );
  }

  Widget _buildBookGridItem(BuildContext context, Book book, int requestCount) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PendingApprovalScreen(book: book),
          ),
        ).then((_) {
          _fetchBookRequests();
        });
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    book.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.book, size: 50, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  requestCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
