import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projectmobile_g9/Login-Regis/login.dart';

String get baseUrl => dotenv.env['BASE_URL'] ?? '';
String get imageUrl => dotenv.env['IMAGE_URL'] ?? '';

class StaffDash extends StatefulWidget {
  const StaffDash({super.key});

  @override
  State<StaffDash> createState() => _LectdashState();
}

class _LectdashState extends State<StaffDash> {
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
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B1A1A),
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

                    // 📚 ปุ่มรีเฟรช
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.blue),
                      title: const Text('Refresh Summary'),
                      onTap: () {
                        Navigator.pop(ctx);
                        fetchSummary();
                      },
                    ),

                    const Divider(height: 1),

                    // 🚪 ปุ่ม Logout
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout', style: TextStyle(color: Colors.red)),
                      onTap: () {
                        Navigator.pop(ctx);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  Future.delayed(const Duration(milliseconds: 150), () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  });
                                },
                                child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 แถวสถิติ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatusCard(color: Colors.blue, title: 'Borrowed', count: borrowed),
                StatusCard(color: Colors.green, title: 'Available', count: available),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatusCard(color: Colors.orange, title: 'Pending', count: pending),
                StatusCard(color: Colors.red, title: 'Disabled', count: disabled),
              ],
            ),
            const SizedBox(height: 32),

            // 🔹 Progress Bars
            buildBar('Borrowed', borrowed / total, Colors.blue),
            buildBar('Available', available / total, Colors.green),
            buildBar('Pending', pending / total, Colors.orange),
            buildBar('Disabled', disabled / total, Colors.red),
          ],
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
      width: 150,
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
