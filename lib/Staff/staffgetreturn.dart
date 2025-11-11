import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectmobile_g9/Login-Regis/login.dart';

const String baseUrl = 'http://192.168.49.1:3000';

class Returnbook extends StatefulWidget {
  const Returnbook({super.key});

  @override
  State<Returnbook> createState() => _ReturnbookState();
}

enum ReturnTab { pending, borrowed, returned }

class _ReturnbookState extends State<Returnbook> {
  ReturnTab current = ReturnTab.pending;
  List<dynamic> items = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchReturnList();
  }

  Future<void> fetchReturnList() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/staff/getreturn'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          items = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> confirmReturn(int borrowId) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/api/staff/return/$borrowId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'received_by': 1}),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Book marked as returned')),
        );
        fetchReturnList();
      } else {
        final msg = json.decode(res.body)['message'] ?? 'Error';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('⚠️ $msg')));
      }
    } catch (e) {
      print('❌ Error confirming return: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7B2020);
    const gold = Color(0xFFB38820);

    final filteredItems = items.where((it) {
      final status = (it['status'] ?? '').toLowerCase();
      if (current == ReturnTab.pending) return status == 'pending';
      if (current == ReturnTab.borrowed) return status == 'borrowed';
      if (current == ReturnTab.returned) return status == 'returned';
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7EFF0),
      appBar: AppBar(
        backgroundColor: maroon,
        centerTitle: true,
        title: const Text(
          'Return Books',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
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
                      title: const Text('Refresh List'),
                      onTap: () {
                        Navigator.pop(ctx);
                        fetchReturnList();
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
                        Navigator.pop(ctx);
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
                                          builder: (_) => const LoginPage(),
                                        ),
                                        (route) => false,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchReturnList,
          ),
        ],
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: maroon))
            : hasError
            ? const Center(
                child: Text(
                  '⚠️ Failed to load data. Please check your connection.',
                  style: TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        _Segment(
                          label: 'Pending',
                          selected: current == ReturnTab.pending,
                          fillColor: gold,
                          borderColor: gold,
                          onTap: () =>
                              setState(() => current = ReturnTab.pending),
                        ),
                        const SizedBox(width: 10),
                        _Segment(
                          label: 'Borrowed',
                          selected: current == ReturnTab.borrowed,
                          fillColor: Colors.blueGrey,
                          borderColor: Colors.blueGrey,
                          onTap: () =>
                              setState(() => current = ReturnTab.borrowed),
                        ),
                        const SizedBox(width: 10),
                        _Segment(
                          label: 'Returned',
                          selected: current == ReturnTab.returned,
                          fillColor: Colors.green[700]!,
                          borderColor: Colors.green[700]!,
                          onTap: () =>
                              setState(() => current = ReturnTab.returned),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? const Center(
                            child: Text(
                              'No books found',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, i) {
                              final it = filteredItems[i];
                              final status = (it['status'] ?? '').toLowerCase();
                              Color statusColor = gold;
                              if (status == 'borrowed') {
                                statusColor = Colors.blueGrey;
                              } else if (status == 'returned') {
                                statusColor = Colors.green[700]!;
                              }

                              return _ReturnCard(
                                borrower: it['borrower'] ?? '-',
                                book: it['book'] ?? '-',
                                from: it['from'] ?? '-',
                                to: it['to'] ?? '-',
                                status: it['status'] ?? '-',
                                statusColor: statusColor,
                                image: it['image'] ?? '',
                                onAction: status == 'borrowed'
                                    ? () => confirmReturn(it['id'])
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.fillColor,
    required this.borderColor,
    this.textColor = Colors.black,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? fillColor : Colors.transparent,
            border: Border.all(color: borderColor, width: 1.8),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : textColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({
    required this.borrower,
    required this.book,
    required this.from,
    required this.to,
    required this.status,
    required this.statusColor,
    required this.image,
    this.onAction,
  });

  final String borrower;
  final String book;
  final String from;
  final String to;
  final String status;
  final Color statusColor;
  final String image;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Borrower: $borrower',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('Book: $book'),
                Text('From: $from'),
                Text('To: $to'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Status: '),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (onAction != null)
                  SizedBox(
                    width: 160,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: onAction,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.black87,
                          width: 1.4,
                        ),
                        backgroundColor: const Color(0xFFEDE9E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Get Return',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              image,
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 110,
                color: const Color(0xFFE5E5E5),
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
