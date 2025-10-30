import 'package:flutter/material.dart';
import 'studenthome.dart';

class RequestPage extends StatefulWidget {
  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  String title = "---- TITLE ----";
  String imagePath = "";
  String status = 'PENDING';

  DateTime? fromDate = DateTime.now();
  DateTime? toDate = DateTime.now();

  bool showInfo = true;
  bool isConfirmed = false;

  void initState() {
    super.initState();
    fromDate = DateTime.now();
    toDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: SizedBox(
              width: double.infinity,
              height: 85,
              child: Stack(
                alignment: Alignment.center,
                children: showInfo
                    ? [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          left: 255,
                          top: 30,
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
                          left: 120,
                          top: 0,
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
                          left: 255,
                          top: 30,
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
                          left: 110,
                          top: 0,
                          child: buildButton(
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
              child: showInfo ? RequestInfo() : Status(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------//

  Widget buildButton({
    required String text,
    required bool active,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 170 : 110,
      height: active ? 55 : 40,
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
            fontSize: active ? 18 : 12,
          ),
        ),
      ),
    );
  }

  Widget RequestInfo() {
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
            Title(title),
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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  'CONFIRM',
                  Colors.green,
                  onPressed: () {
                    setState(() {
                      isConfirmed = true;
                      showInfo = false;
                    });
                  },
                ),
                Button(
                  'CANCEL',
                  Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => StudentHome()),
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

  Widget Status() {
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
            height: 230,
            padding: const EdgeInsets.all(16),
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
                        const SizedBox(height: 10),
                        Title(title),
                      ],
                    ),
                    Column(
                      children: [
                        date(date: fromDate),
                        const SizedBox(height: 10),
                        date(date: toDate),
                        const SizedBox(height: 10),
                        statusBox(status),
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
            child: Button(
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
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'No',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -12,
            left: 20,
            child: SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.black26),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Return Book'),
                      content: const Text(
                        'Do you want to return this book?',
                        style: TextStyle(fontSize: 15),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isConfirmed = false;
                              showInfo = true;
                            });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Book returned successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'No',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'RETURN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget Title(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF8B0000),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
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

  Widget statusBox(String text) {
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
