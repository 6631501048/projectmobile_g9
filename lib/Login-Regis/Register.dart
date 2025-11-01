import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController(); // ✅ controller สำหรับ Username

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  // 🔹 ฟังก์ชันเรียก API /register
  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('http://192.168.49.1/register'); // สำหรับ Emulator (เปลี่ยนได้)
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameCtrl.text.trim(),
          'password': _passCtrl.text.trim(),
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${data["message"]}')),
        );
        Navigator.pop(context); // กลับไปหน้า Login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Register failed, please try again')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const deepRed = Color(0xFF7B2020);

    return Scaffold(
      body: Stack(
        children: [
          // BG image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Blackground.png', // ✅ เปลี่ยน path ให้ตรงกับ LoginPage
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFEAE5), Color(0xFFFFC0C0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'MFU Library',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Username
                        _SoftInput(
                          controller: _usernameCtrl,
                          hint: 'Username',
                          leading: Icons.person_outline,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Please enter username';
                            if (t.length < 3) return 'At least 3 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email (optional, ไม่ส่งไป DB)
                        _SoftInput(
                          controller: _emailCtrl,
                          hint: 'Email address',
                          keyboardType: TextInputType.emailAddress,
                          leading: Icons.email_outlined,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Please enter email';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(t)) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _SoftInput(
                          controller: _passCtrl,
                          hint: 'Password',
                          leading: Icons.lock_outline,
                          obscureText: _obscure1,
                          trailing: IconButton(
                            onPressed: () => setState(() => _obscure1 = !_obscure1),
                            icon: Icon(
                              _obscure1
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter password';
                            if (v.length < 6) return 'At least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        _SoftInput(
                          controller: _confirmCtrl,
                          hint: 'Confirm Password',
                          leading: Icons.lock_person_outlined,
                          obscureText: _obscure2,
                          trailing: IconButton(
                            onPressed: () =>
                                setState(() => _obscure2 = !_obscure2),
                            icon: Icon(
                              _obscure2
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Please confirm password';
                            if (v != _passCtrl.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // 🔹 ปุ่ม Sign up (เชื่อม API)
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: deepRed,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isLoading ? null : registerUser,
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Bottom text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Have an account? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Click',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: deepRed,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// กล่องอินพุตแบบโปร่งนุ่ม
class _SoftInput extends StatelessWidget {
  const _SoftInput({
    required this.hint,
    this.controller,
    this.leading,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final String hint;
  final TextEditingController? controller;
  final IconData? leading;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x55B73A3A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (leading != null) ...[
            Icon(leading, color: Colors.black54),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black54),
                isCollapsed: true,
                border: InputBorder.none,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
