import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jamur/pages/registerEmail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  final String backendUrl =
      'https://c969-149-113-224-229.ngrok-free.app/api/auth/login'; // Ganti sesuai IP server kamu

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Email and password cannot be empty");
      return;
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      _showMessage("Format email tidak valid");
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('idToken', data['idToken']);
        await prefs.setString('uid', data['uid']);
        widget.onLoginSuccess();
      } else {
        _showMessage(data['detail'] ?? "Login failed");
      }
    } catch (e) {
      _showMessage("Something wrong: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF09A46E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Header
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF50555C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Welcome message
                  const Text(
                    'Hey 👋, welcome back!',
                    style: TextStyle(fontSize: 20, color: Color(0xFFA9AFBC)),
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    hint: 'example@mail.com',
                    icon: Icons.mail_outline,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF09A46E),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFF09A46E,
                        ).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Forgot password
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF09A46E),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                  // Register prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Doesnt have an account? ',
                        style: TextStyle(
                          color: Color(0xFF50555C),
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigasi ke halaman register
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const EmailVerificationPage(),
                            ),
                          );
                          // Replace with your registration logic
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Color(0xFF09A46E),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom indicator
                ],
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF09A46E)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate social login
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, you would implement actual social login here
    _showMessage("Login with this $provider not available yet");

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Color(0xFF50555C), fontSize: 16),

        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFA9AFBC)),
          prefixIcon: Icon(icon, color: const Color(0xFFA9AFBC)),
          prefixIconConstraints: const BoxConstraints(minWidth: 60),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Blue
    final Paint bluePaint =
        Paint()
          ..color = const Color(0xFF4285F4)
          ..style = PaintingStyle.fill;

    // Red
    final Paint redPaint =
        Paint()
          ..color = const Color(0xFFEA4335)
          ..style = PaintingStyle.fill;

    // Yellow
    final Paint yellowPaint =
        Paint()
          ..color = const Color(0xFFFBBC05)
          ..style = PaintingStyle.fill;

    // Green
    final Paint greenPaint =
        Paint()
          ..color = const Color(0xFF34A853)
          ..style = PaintingStyle.fill;

    // Draw the Google 'G'
    final Path path = Path();

    // Red part (left)
    path.moveTo(width * 0.35, height * 0.25);
    path.lineTo(width * 0.35, height * 0.75);
    path.arcTo(
      Rect.fromLTWH(width * 0.25, height * 0.25, width * 0.5, height * 0.5),
      3.14, // pi
      1.57, // pi/2
      false,
    );
    canvas.drawPath(path, redPaint);

    // Green part (bottom)
    path.reset();
    path.moveTo(width * 0.75, height * 0.75);
    path.lineTo(width * 0.35, height * 0.75);
    path.arcTo(
      Rect.fromLTWH(width * 0.25, height * 0.25, width * 0.5, height * 0.5),
      1.57, // pi/2
      1.57, // pi/2
      false,
    );
    canvas.drawPath(path, greenPaint);

    // Yellow part (right)
    path.reset();
    path.moveTo(width * 0.75, height * 0.25);
    path.lineTo(width * 0.75, height * 0.75);
    path.arcTo(
      Rect.fromLTWH(width * 0.25, height * 0.25, width * 0.5, height * 0.5),
      0,
      1.57, // pi/2
      false,
    );
    canvas.drawPath(path, yellowPaint);

    // Blue part (top)
    path.reset();
    path.moveTo(width * 0.35, height * 0.25);
    path.lineTo(width * 0.75, height * 0.25);
    path.arcTo(
      Rect.fromLTWH(width * 0.25, height * 0.25, width * 0.5, height * 0.5),
      4.71, // 3*pi/2
      1.57, // pi/2
      false,
    );
    canvas.drawPath(path, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
