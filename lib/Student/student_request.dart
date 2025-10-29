import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  int selectedIndex = 0;
  String title = "";
  String imagePath = "";

  DateTime? fromDate = DateTime.now();
  DateTime? toDate = DateTime.now();
  bool showInfo = true;
  bool isConfirmed = false;
  String from = '';
  String to = '';

  @override
  void initState() {
    super.initState();
    fromDate = DateTime.now();
    toDate = DateTime.now().add(const Duration(days: 1));
    from = '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}';
    to = '${toDate!.day}/${toDate!.month}/${toDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 75),
            child: SizedBox(
              width: double.infinity,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: showInfo
                    ? [
                        _tabButton('Request Info', true, () {}),
                        _tabButton('Status', false, () {
                          setState(() {
                            showInfo = false;
                          });
                        }),
                      ]
                    : [
                        _tabButton('Status', true, () {}),
                        _tabButton('Request Info', false, () {
                          setState(() {
                            showInfo = true;
                            isConfirmed = false;
                          });
                        }),
                      ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: showInfo ? _buildRequestInfo() : _buildStatus(),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------

  Widget _tabButton(String text, bool active, VoidCallback onPressed) {
    return Align(
      alignment: active ? Alignment.topLeft : Alignment.bottomRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: active ? 180 : 140,
        height: active ? 60 : 45,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6B1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(30),
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
              fontSize: active ? 20 : 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestInfo() {
    return Center(
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
            _redTitle(title),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imagePath.isNotEmpty
                      ? Image.asset(
                          imagePath,
                          width: 110,
                          height: 110,
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
                Column(
                  children: [
                    const Text(
                      'FROM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _dateBox(fromDate),
                    const SizedBox(height: 10),
                    const Text(
                      'TO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _dateBox(toDate),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _button(
                  'CONFIRM',
                  Colors.green,
                  onPressed: () {
                    setState(() {
                      isConfirmed = true;
                      showInfo = false;
                    });
                  },
                ),
                _button(
                  'CANCEL',
                  Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cancelled!'),
                        backgroundColor: Colors.red,
                      ),
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

  Widget _buildStatus() {
    if (!isConfirmed) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 150),
          child: Text(
            'No booking yet',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ),
      );
    }

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _redTitle(title),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imagePath.isNotEmpty
                          ? Image.asset(
                              imagePath,
                              width: 110,
                              height: 110,
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
                    Column(
                      children: [
                        _dateBox(fromDate),
                        const SizedBox(height: 10),
                        _dateBox(toDate),
                        const SizedBox(height: 10),
                        _statusBox('PENDING'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: -20,
            left: 180,
            child: _button(
              'CANCEL',
              Colors.red[800]!,
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  isConfirmed = false;
                  showInfo = true;
                });
              },
            ),
          ),
          Positioned(
            bottom: -12,
            left: 20,
            child: _button(
              'RETURN',
              Colors.black,
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  isConfirmed = false;
                  showInfo = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Book returned successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------

  Widget _dateBox(DateTime? date) {
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

  Widget _redTitle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF8B0000),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _button(
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
          side: const BorderSide(color: Colors.black26),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusBox(String text) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
