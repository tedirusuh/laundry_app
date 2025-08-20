// lib/screens/splash_screen.dart
import 'package:app_laundry/app_routes.dart';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/screens/home_screen.dart';
import 'package:app_laundry/screens/profile_screen.dart';
import 'package:app_laundry/utils/session_manager.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Tunggu 2 detik untuk efek splash
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final session = await SessionManager.getSession();
      if (session != null && session['user'] is User) {
        // Jika ada sesi, simpan token dan langsung ke HomeScreen
        UserSession.token = session['token'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(user: session['user'] as User),
          ),
        );
      } else {
        // Jika tidak ada sesi, ke halaman Login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan UI splash screen tetap sama
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 174, 240),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/poto_splash.png', height: 180),
            const SizedBox(height: 32),
            const Text(
              'Laundry Express',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2962FF),
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: Color(0xFF2962FF)),
          ],
        ),
      ),
    );
  }
}
