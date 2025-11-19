import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projectmobile_g9/Login-Regis/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl => dotenv.env['BASE_URL'] ?? '';
String get imageUrl => dotenv.env['IMAGE_URL'] ?? '';

class Lectprofile extends StatefulWidget {
  final int userId;
  const Lectprofile({super.key, required this.userId});

  @override
  State<Lectprofile> createState() => _LectprofileState();
}

class _LectprofileState extends State<Lectprofile> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/user/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        setState(() {
          userData = json.decode(res.body);
        });
      } else {
        print('❌ Error fetching user: ${res.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
  }

  // 🏷️ คืนค่า role label ที่อ่านง่าย
  String getRoleLabel(dynamic roleValue) {
    switch (roleValue.toString().toLowerCase()) {
      case '1':
      case 'admin':
        return 'ADMIN';
      case '2':
      case 'lecturer':
        return 'LECTURER';
      case 'staff':
        return 'STAFF';
      case '0':
      case 'student':
      default:
        return 'STUDENT';
    }
  }

  // 🎨 เปลี่ยนสีตาม role
  Color getRoleColor(dynamic roleValue) {
    switch (roleValue.toString().toLowerCase()) {
      case '1':
      case 'admin':
        return const Color(0xFF6A1B9A); // ม่วง
      case '2':
      case 'lecturer':
        return const Color(0xFF2E7D32); // เขียว
      case 'staff':
        return const Color(0xFF0277BD); // ฟ้า
      case '0':
      case 'student':
      default:
        return const Color(0xFF8B1A1A); // แดง
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF8B1A1A),
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                "Are you sure to Logout?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF8B1A1A),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1A1A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text("Sure", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF8B1A1A)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF8B1A1A)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = userData?['username'] ?? '';
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '?';
    final roleColor = getRoleColor(userData?['role']);
    final roleLabel = getRoleLabel(userData?['role']);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      appBar: AppBar(
        title: const Text(
          "Lecturer Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32), // เขียวตาม role Lecturer
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 🧑‍🎓 Avatar
            CircleAvatar(
              radius: 45,
              backgroundColor: roleColor,
              child: Text(
                firstLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📋 กล่องข้อมูล
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F3F3),
                  border: Border.all(color: roleColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                child: userData == null
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roleLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: roleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "User : ${userData!['username']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Email : ${userData!['email'] ?? '-'}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const Spacer(),

            // 🔻 ปุ่ม Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showLogoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: roleColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Log out",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
