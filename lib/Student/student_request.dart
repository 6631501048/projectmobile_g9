import 'package:flutter/material.dart';
import 'package:projectmobile_g9/Student/studenthome.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestPage extends StatefulWidget {
  final int? bookId;
  final String? title;
  final String? image;
  final int userId;
  final String initialTab;

  const RequestPage({
    super.key,
    this.bookId,
    this.title,
    this.image,
    required this.userId,
    this.initialTab = 'status',
  });

  @override
  State<RequestPage> createState() => _RequestPageState();
}

const String ip = "192.168.49.1";
const String port = "3000";

class _RequestPageState extends State<RequestPage> {
  String title = "";
  String image = "";
  String status = '';

  DateTime? fromDate = DateTime.now();
  DateTime? toDate = DateTime.now();
  List<dynamic> borrowList = [];
  bool isLoading = true;

  bool showInfo = true;
  bool isConfirmed = false;

  @override
  void initState() {
    super.initState();

    fromDate = DateTime.now();
    toDate = DateTime.now().add(const Duration(days: 1));

    title = widget.title ?? '';
    image = widget.image ?? '';

    if (widget.bookId != null && (title.isEmpty || image.isEmpty)) {
      fetchBook();
    }
    if (widget.initialTab == 'status') {
      showInfo = false;
    }
    fetchBorrowData();
  }

  Future<void> confirmBorrow() async {
    final userId = widget.userId;
    final url = Uri.parse('$baseUrl/borrow');
    final body = jsonEncode({'userId': userId, 'bookId': widget.bookId});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Borrow request sent')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('❌ Borrow failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> fetchBook() async {
    if (widget.bookId == null) return;
    final url = Uri.parse("http://$ip:$port/books/${widget.bookId}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          title = data['title'] ?? '';
          image = data['image'] ?? '';
        });
      } else {
        print('Failed to load book: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching book: $e');
    }
  }

  Future<void> fetchBorrowData() async {
    final userId = widget.userId;
    final url = Uri.parse("http://$ip:$port/borrow/$userId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          borrowList = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      isLoading = true;
    });
    await fetchBorrowData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * 0.35,
            child: Stack(
              alignment: Alignment.center,
              children: showInfo
                  ? [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        left: MediaQuery.of(context).size.width * 0.43,
                        child: buildButton(
                          text: 'Status',
                          active: false,
                          onPressed: () {
                            setState(() {
                              showInfo = false;
                            });
                          },
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        left: MediaQuery.of(context).size.width * 0.1,
                        child: buildButton(
                          text: 'Request Info',
                          active: true,
                          onPressed: () {},
                        ),
                      ),
                    ]
                  : [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        left: MediaQuery.of(context).size.width * 0.46,
                        child: buildButton(
                          text: 'Request Info',
                          active: false,
                          onPressed: () {
                            setState(() {
                              isConfirmed = false;
                              showInfo = true;
                            });
                          },
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        left: MediaQuery.of(context).size.width * 0.06,
                        child: buildButton(
                          text: 'Status',
                          active: true,
                          onPressed: () {},
                        ),
                      ),
                    ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: showInfo
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: RequestInfo(),
                      ),
                    )
                  : Status(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton({
    required String text,
    required bool active,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 170,
      height: 55,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6B1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6B1A1A)),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF6B1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget RequestInfo() {
    if (widget.bookId == null || title.isEmpty || image.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Text(
            'Please select a book first',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 1),
            buildRequestTitle(title),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: image.isNotEmpty
                        ? Image(
                            image: _bookImage(image),
                            width: 120,
                            height: 130,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 110,
                            height: 110,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                            ),
                          ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    children: [
                      const Text(
                        'FROM',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      date(date: fromDate),
                      const SizedBox(height: 10),
                      const Text(
                        'TO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      date(date: toDate),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  'CONFIRM',
                  Colors.green,
                  onPressed: () async {
                    if (widget.bookId == null) {
                      setState(() {
                        title = '';
                        image = '';
                      });
                      return;
                    }
                    final alreadyPending = borrowList.any(
                      (borrow) =>
                          borrow['book_id'] == widget.bookId &&
                          borrow['status'] == 'pending',
                    );

                    if (alreadyPending) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You already requested this book'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    try {
                      await ApiClient.borrow(
                        userId: widget.userId,
                        bookId: widget.bookId!,
                        borrowDate: fromDate?.toIso8601String(),
                        returnDate: toDate?.toIso8601String(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Request sent successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      await fetchBorrowData();
                      setState(() {
                        isConfirmed = true;
                        showInfo = false;
                        title = '';
                        image = '';
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to send request: $e')),
                      );
                    }
                  },
                ),

                Button(
                  'CANCEL',
                  Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentHome(userId: widget.userId),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _bookImage(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) return const AssetImage('assets/images/ready.jpg');
    if (s.startsWith('http')) return NetworkImage(s);
    if (s.endsWith('.jpg') || s.endsWith('.png')) {
      return NetworkImage('http://$ip:$port/uploads/$s');
    }
    return AssetImage('assets/images/$s');
  }

  Widget Status() {
    if (borrowList.isEmpty) {
      return const Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Text(
            'No booking yet',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: borrowList.length,
      itemBuilder: (context, index) {
        final borrow = borrowList[index];
        final title = borrow['title'] ?? '';
        final imagePath = borrow['image'] ?? '';
        final borrowDate = borrow['borrow_date'] != null
            ? DateTime.parse(borrow['borrow_date']).toLocal()
            : null;
        final returnDate = borrow['return_date'] != null
            ? DateTime.parse(borrow['return_date']).toLocal()
            : null;
        final status = borrow['status'] ?? '';

        return Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imagePath.isNotEmpty
                              ? Image.network(
                                  imagePath.startsWith('http')
                                      ? imagePath
                                      : 'http://$ip:$port/uploads/$imagePath',
                                  width: 110,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 110,
                                      height: 110,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 110,
                                  height: 110,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        buildStatusTitle(title),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        date(date: borrowDate),
                        const SizedBox(height: 10),
                        date(date: returnDate),
                        const SizedBox(height: 10),
                        statusBox(status),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 40,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Button(
                            'RETURN',
                            Colors.black,
                            textColor: Colors.white,
                            onPressed: () async {
                              final currentStatus = borrowList[index]['status'];

                              if (currentStatus != 'borrowed') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Can return only if Borrowed',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              final borrowId = borrowList[index]['id'];
                              final url = Uri.parse(
                                "http://$ip:$port/return/$borrowId",
                              );

                              try {
                                final response = await http.put(
                                  url,
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({'status': 'returned'}),
                                );

                                if (response.statusCode == 200) {
                                  setState(() {
                                    borrowList[index]['status'] = 'returned';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Book returned successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed: ${response.body}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 40,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Button(
                            'CANCEL',
                            Colors.red[800]!,
                            textColor: Colors.white,
                            onPressed: () async {
                              final currentStatus = borrowList[index]['status'];
                              if (currentStatus != 'pending') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Can cancel only if Pending'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Cancel'),
                                  content: const Text(
                                    'Are you sure you want to cancel this booking?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text(
                                        'No',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final borrowId = borrowList[index]['id'];
                                final url = Uri.parse(
                                  'http://$ip:$port/borrow/$borrowId',
                                );

                                try {
                                  final response = await http.delete(
                                    url,
                                    headers: {
                                      'Content-Type': 'application/json',
                                    },
                                  );

                                  if (response.statusCode == 200) {
                                    setState(() {
                                      borrowList.removeAt(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Booking cancelled and deleted successfully',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to cancel booking: ${response.body}',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget date({required DateTime? date}) {
    final d = date ?? DateTime.now();
    return Container(
      width: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18),
          const SizedBox(width: 8),
          Text(
            '${d.day}/${d.month}/${d.year}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildRequestTitle(String text) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => Dialog(
            backgroundColor: Colors.white.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF8B0000),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Tooltip(
            message: text,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatusTitle(String text) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => Dialog(
            backgroundColor: Colors.white.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.3,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B0000),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Tooltip(
          message: text,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget Button(
    String label,
    Color color, {
    Color textColor = Colors.white,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.black26),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget statusBox(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'borrowed':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'pending':
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      width: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: textColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class ApiClient {
  static Future<void> borrow({
    required int userId,
    required int bookId,
    required String? borrowDate,
    required String? returnDate,
  }) async {
    final url = Uri.parse('http://$ip:$port/borrow');

    final body = {
      'userId': userId,
      'bookId': bookId,
      'borrowDate': borrowDate,
      'returnDate': returnDate,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to borrow book: ${response.statusCode}');
    }
  }
}
