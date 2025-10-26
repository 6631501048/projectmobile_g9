import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  final String title;
  final String imagePath;

  const RequestPage({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  int selectedIndex = 0;

  DateTime? fromDate = DateTime.now();
  DateTime? toDate = DateTime.now();
  bool showInfo = true;
  bool isConfirmed = false;
  String from = '';
  String to = '';

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
            padding: const EdgeInsets.only(top: 80),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: showInfo
                    ? [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          left: 200,
                          top: 30,
                          child: _buildButton(
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
                          left: 50,
                          top: 0,
                          child: _buildButton(
                            text: 'Request Info',
                            active: true,
                            onPressed: () {},
                          ),
                        ),
                      ]
                    : [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          left: 210,
                          top: 30,
                          child: _buildButton(
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
                          left: 50,
                          top: 0,
                          child: _buildButton(
                            text: 'Status',
                            active: true,
                            onPressed: () {},
                          ),
                        ),
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

  Widget _buildButton({
    required String text,
    required bool active,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 190 : 130,
      height: active ? 60 : 45,
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
            fontSize: active ? 22 : 16,
          ),
        ),
      ),
    );
  }

  Widget _topButton(String title, int index) {
    final bool isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF8B0000) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
          border: Border.all(
            color: isActive ? const Color(0xFF8B0000) : Colors.black,
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
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
            _redTitle(widget.title),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.imagePath,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  children: [
                    const Text(
                      'FROM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    _dateBox(date: fromDate),
                    const SizedBox(height: 10),
                    const Text(
                      'TO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    _dateBox(date: toDate),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  'CONFIRM',
                  Colors.green,
                  onPressed: () {
                    setState(() {
                      isConfirmed = true;
                      showInfo = false;
                    });
                  },
                ),
                _actionButton(
                  'CANCEL',
                  Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 150),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                _redTitle(widget.title),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        widget.imagePath,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      children: [
                        _dateBox(date: fromDate),
                        const SizedBox(height: 10),
                        _dateBox(date: toDate),
                        const SizedBox(height: 10),
                        _statusBox('PENDING'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '** Pending staff approval',
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          Positioned(
            bottom: -20,
            left: 190,
            child: _actionButton(
              'CANCEL',
              Colors.red[800]!,
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Cancellation'),
                    content: const Text(
                      'Are you sure you want to cancel?',
                      style: TextStyle(fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'No',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isConfirmed = false;
                            showInfo = true;
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Yes',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox({required DateTime? date}) {
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8B0000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionButton(
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

  Widget _statusBox(String text) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
