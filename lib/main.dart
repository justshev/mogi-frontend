import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamur/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if user is logged in
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wello App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF09A46E),
          primary: const Color(0xFF09A46E),
        ),
        useMaterial3: true,
      ),
      home:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isLoggedIn
              ? HomeScreen()
              : LoginPage(onLoginSuccess: _onLoginSuccess),
    );
  }

  // Called when login is successful
  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }
}
