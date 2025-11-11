import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://192.168.49.1:3000';

class Lectdash extends StatefulWidget {
  const Lectdash({super.key});

   @override
  State<Lectdash> createState() => _LectdashState();
}

class _LectdashState extends State<Lectdash> {
  int borrowed = 0;
  int available = 0;
  int disabled = 0;
  int pending = 0;
  int total = 1; // กันหารศูนย์
  bool isLoading = true;

  Future<void> fetchSummary() async {
  try {
    print('🌐 Fetching summary...');
    final res = await http.get(Uri.parse('$baseUrl/api/dashboard/summary'));
    print('📦 Response: ${res.statusCode}');
    print('📦 Body: ${res.body}');
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      print('✅ Decoded: $data');
      setState(() {
        borrowed = data['borrowed'] ?? 0;
        available = data['available'] ?? 0;
        disabled = data['disabled'] ?? 0;
        pending = data['pending'] ?? 0;
        total = data['total'] ?? 1;
        isLoading = false;
      });
    } else {
      print('❌ Fetch failed: ${res.statusCode}');
    }
  } catch (e) {
    print('⚠️ Exception: $e');
  }
}

  @override
  void initState() {
    super.initState();
    fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B1A1A))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B1A1A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchSummary,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ✅ Status Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: StatusCard(color: Colors.red, title: 'Borrowed Assets', count: borrowed)),
                  const SizedBox(width: 12),
                  Expanded(child: StatusCard(color: Colors.green, title: 'Available Assets', count: available)),
                  const SizedBox(width: 12),
                  Expanded(child: StatusCard(color: Colors.orange, title: 'Disabled Assets', count: disabled)),
                  const SizedBox(width: 12),
                  Expanded(child: StatusCard(color: Colors.blue, title: 'Pending Borrow', count: pending)),
                ],
              ),
              const SizedBox(height: 24),

              // ✅ Progress Bars
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assets Overview',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        buildBar('Borrowed', borrowed / total, Colors.red),
                        buildBar('Available', available / total, Colors.green),
                        buildBar('Disabled', disabled / total, Colors.orange),
                        buildBar('Pending Borrow', pending / total, Colors.blue),
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

  Widget buildBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: color.withOpacity(0.2),
            minHeight: 20,
          ),
        ],
      ),
    );
  }
}

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
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}