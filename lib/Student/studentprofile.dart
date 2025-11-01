import 'package:flutter/material.dart';
import 'package:projectmobile_g9/Login-Regis/Login.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
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
                Navigator.of(context).pop(); // ปิด popup
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  LoginPage(),
                  ), // ✅ ไปหน้า Login
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1A1A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F3F3),
                  border: Border.all(color: const Color(0xFF8B1A1A)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(14),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Student",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "User : 6631501049",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Email : 6631501049@lamduan.mfu.ac.th",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showLogoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1A1A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
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
            ],
          ),
        ),
      ),
    );
  }
}
