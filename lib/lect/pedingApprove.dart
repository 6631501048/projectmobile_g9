import 'package:flutter/material.dart';
import 'model.dart';

const Color kPrimaryColor = Color(0xFF8A0E0E);
const Color kAccentColor = Color(0xFF2E7D32);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class PendingApprovalScreen extends StatefulWidget {
  final Book book;

  const PendingApprovalScreen({Key? key, required this.book}) : super(key: key);

  @override
  _PendingApprovalScreenState createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  List<BorrowRequest> _requestsForThisBook = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  void _fetchPendingRequests() {
    setState(() {
      _requestsForThisBook = mockRequests
          .where(
            (req) => req.bookId == widget.book.id && req.status == 'pending',
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Pending Approval",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _requestsForThisBook.isEmpty
          ? Center(
              child: Text(
                "No pending requests for this book.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              itemCount: _requestsForThisBook.length,
              itemBuilder: (context, index) {
                final request = _requestsForThisBook[index];
                return _buildRequestListItem(context, request);
              },
            ),
    );
  }

  Widget _buildRequestListItem(BuildContext context, BorrowRequest request) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: kPrimaryColor,
          child: Icon(Icons.person_outline, color: Colors.white),
        ),
        title: Text(
          "Borrower: ${request.userName}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Text(
          "Date: ${request.fromDate} - ${request.toDate}",
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => _showApprovalDialog(context, request),
      ),
    );
  }

  Future<void> _showApprovalDialog(
      BuildContext context, BorrowRequest request) {
    final book = widget.book;

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.transparent,
          child: _buildDialogContent(dialogContext, request, book),
        );
      },
    );
  }

  Widget _buildDialogContent(
      BuildContext dialogContext, BorrowRequest request, Book book) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Text(
              book.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    book.imageUrl,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.book, size: 80),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!)),
                  child: Column(
                    children: [
                      _buildDateRow("From", request.fromDate),
                      const Divider(height: 12),
                      _buildDateRow("To", request.toDate),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Borrower : ${request.userName}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() {
                            mockRequests
                                .firstWhere((r) => r.id == request.id)
                                .status = 'approved';
                            _fetchPendingRequests();
                          });
                          Navigator.of(dialogContext).pop();
                          if (_requestsForThisBook.isEmpty) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Approve",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() {
                            mockRequests
                                .firstWhere((r) => r.id == request.id)
                                .status = 'rejected';
                            _fetchPendingRequests();
                          });
                          Navigator.of(dialogContext).pop();
                          if (_requestsForThisBook.isEmpty) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Reject",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 16, color: Colors.black87)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(date,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(width: 8),
              Icon(Icons.calendar_today,
                  size: 16, color: Colors.grey[700]),
            ],
          ),
        ),
      ],
    );
  }
}
