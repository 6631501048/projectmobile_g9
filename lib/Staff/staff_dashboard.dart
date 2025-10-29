import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StaffDash(),
  ));
}

class StaffDash extends StatelessWidget {
  const StaffDash({super.key});

  @override
  Widget build(BuildContext context) {
    // ข้อมูลตัวอย่าง
    int borrowed = 12;
    int available = 25;
    int disabled = 3;
    int maxAssets = 30; // สำหรับ progress bar

    return Scaffold(
      appBar: AppBar(
        title: const Text('StaffDash'),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B1A1A),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Status Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: StatusCard(
                          color: Colors.red,
                          title: 'Borrowed Assets',
                          count: borrowed)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: StatusCard(
                          color: Colors.green,
                          title: 'Available Assets',
                          count: available)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: StatusCard(
                          color: Colors.orange,
                          title: 'Disabled Assets',
                          count: disabled)),
                ],
              ),
              const SizedBox(height: 24),

              // Dashboard Graph แบบง่าย
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assets Overview',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Borrowed
                        const Text('Borrowed'),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: borrowed / maxAssets,
                          color: Colors.red,
                          backgroundColor: Colors.red.withOpacity(0.2),
                          minHeight: 20,
                        ),
                        const SizedBox(height: 16),

                        // Available
                        const Text('Available'),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: available / maxAssets,
                          color: Colors.green,
                          backgroundColor: Colors.green.withOpacity(0.2),
                          minHeight: 20,
                        ),
                        const SizedBox(height: 16),

                        // Disabled
                        const Text('Disabled'),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: disabled / maxAssets,
                          color: Colors.orange,
                          backgroundColor: Colors.orange.withOpacity(0.2),
                          minHeight: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Status Card
class StatusCard extends StatelessWidget {
  final Color color;
  final String title;
  final int count;

  const StatusCard({
    super.key,
    required this.color,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}