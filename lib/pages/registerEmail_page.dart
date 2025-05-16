import 'package:flutter/material.dart';
import 'login_page.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 24.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0CAB7E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),

            // Welcome text
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 40.0,
              ),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Selamat bergabung ',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A),
                        height: 1.2,
                      ),
                    ),
                    TextSpan(text: '🎉', style: TextStyle(fontSize: 36)),
                  ],
                ),
              ),
            ),

            // Subtitle text
            const Padding(
              padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
              child: Text(
                'Kami akan memverifikasi apakah email yang kamu masukan sudah ada atau belum',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFA0A0A0),
                  height: 1.4,
                ),
              ),
            ),

            // Email input field
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 40.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'example@mail.com',
                    hintStyle: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFA0A0A0),
                    ),
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4A4A4A),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ),

            const Spacer(),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Add your verification logic here
                    if (_emailController.text.isNotEmpty) {
                      // Process the email
                      print('Verifying email: ${_emailController.text}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0CAB7E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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
