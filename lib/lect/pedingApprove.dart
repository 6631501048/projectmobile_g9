import 'package:flutter/material.dart';
import 'model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'http://192.168.49.1:3000';
const Color kPrimaryColor = Color(0xFF8A0E0E);
const Color kAccentColor = Color(0xFF2E7D32);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class PendingApprovalScreen extends StatefulWidget {
  final Book book;
  const PendingApprovalScreen({Key? key, required this.book}) : super(key: key);

  @override
  _PendingApprovalScreenState createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen>
    with SingleTickerProviderStateMixin {
  List<BorrowRequest> _requests = [];
  bool isLoading = true;
  bool isRefreshing = false;

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _rotationController.repeat(); // เริ่มหมุนไว้ก่อน
    _fetchRequests();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    setState(() => isRefreshing = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/staff/getreturn'));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        final filtered = data.where((r) {
          final matchBook =
              (r['book']?.toString() ?? '').trim() == widget.book.title.trim();
          final matchStatus =
              (r['status']?.toString() ?? '').toLowerCase() == 'pending';
          return matchBook && matchStatus;
        }).toList();

        setState(() {
          _requests = filtered.map((r) => BorrowRequest.fromJson(r)).toList();
          isLoading = false;
          isRefreshing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Refreshed successfully')),
        );
      } else {
        setState(() {
          isLoading = false;
          isRefreshing = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching requests: $e');
      setState(() => isRefreshing = false);
    }
  }

  Future<void> _approveRequest(int borrowId) async {
    await http.put(
      Uri.parse('$baseUrl/approve/$borrowId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'approverId': 2}),
    );
    _fetchRequests();
  }

  Future<void> _rejectRequest(int borrowId) async {
    await http.put(
      Uri.parse('$baseUrl/return/$borrowId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': 'rejected'}),
    );
    _fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Pending Approvals",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          AnimatedBuilder(
            animation: _rotationController,
            builder: (_, child) => Transform.rotate(
              angle: isRefreshing ? _rotationController.value * 6.3 : 0,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: "Refresh",
                onPressed: isRefreshing ? null : _fetchRequests,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRequests,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _requests.isEmpty
                ? const Center(child: Text("No pending requests"))
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final req = _requests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text("Borrower: ${req.borrower}"),
                          subtitle:
                              Text("From ${req.fromDate} → ${req.toDate}"),
                          trailing: Wrap(
                            spacing: 10,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                onPressed: () => _approveRequest(req.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.red),
                                onPressed: () => _rejectRequest(req.id),
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
