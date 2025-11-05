import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Register.dart';
import 'package:projectmobile_g9/Student/studenthome.dart';
import 'package:projectmobile_g9/Staff/staffhome.dart';
import 'package:projectmobile_g9/lect/lec.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscure = true;
  bool isLoading = false;

  // 🔹 ฟังก์ชันเรียก API /login
  Future<void> loginUser() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('http://192.168.49.1:3000/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final role = data['role'];
        final username = data['username'];
        final userId = data['id']; // ✅ ประกาศตัวแปรนี้เพิ่ม

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Welcome, $username!')));

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StaffBookStoreApp()),
          );
        } else if (role == 'lecturer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LectHome()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentHome(userId: userId), // ✅ ส่งต่อไปที่นี่
            ),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังภาพ
          Positioned.fill(
            child: Image.asset(
              'assets/images/Blackground.png',
              fit: BoxFit.cover,
            ),
          ),

          // เนื้อหาหลัก
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MFU Library',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // ช่อง Username
                Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.shade100),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Username',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ช่อง Password
                Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.shade100),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ปุ่ม Login
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2020),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 8,
                  ),
                  onPressed: isLoading ? null : loginUser,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 15),

                // ข้อความใต้ปุ่ม Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have account? ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Click',
                        style: TextStyle(
                          color: Color(0xFF8B1A1A),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
