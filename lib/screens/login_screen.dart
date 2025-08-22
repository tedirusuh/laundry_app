// lib/screens/login_screen.dart
import 'package:app_laundry/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/utils/constants.dart';
import 'package:app_laundry/screens/home_screen.dart';
import 'package:app_laundry/utils/session_manager.dart';
import 'package:app_laundry/screens/profile_screen.dart';

// --- 1. TAMBAHKAN IMPORT INI ---
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- 2. TAMBAHKAN FUNGSI BARU UNTUK MENYIMPAN TOKEN ---
  Future<void> _updateFcmToken(String apiToken) async {
    try {
      // Minta izin notifikasi dari pengguna
      await FirebaseMessaging.instance.requestPermission();

      // Dapatkan token unik perangkat ini
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        // Kirim token ke backend Laravel untuk disimpan
        await http.post(
          Uri.parse('$API_URL/user/update-fcm-token'), // Endpoint baru
          headers: {
            'Authorization': 'Bearer $apiToken', // Gunakan token login
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({'fcm_token': fcmToken}),
        );
      }
    } catch (e) {
      // Jika gagal, cetak error tapi jangan hentikan proses login
      debugPrint("Gagal mengupdate FCM token: $e");
    }
  }

  void _loginUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$API_URL/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final user = User.fromJson(responseData['user']);
        final token = responseData['token'];

        await SessionManager.saveSession(user, token);
        UserSession.token = token;

        // --- 3. PANGGIL FUNGSI UNTUK MENGIRIM TOKEN SETELAH LOGIN SUKSES ---
        await _updateFcmToken(token);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${responseData['message']}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terjadi kesalahan jaringan.')));
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2962FF);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 174, 240),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text('Sign In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue)),
                const SizedBox(height: 20),
                Image.asset('assets/login.png', height: 180),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration:
                      _buildInputDecoration('E-mail', Icons.email_outlined),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Email tidak valid'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration:
                      _buildInputDecoration('Password', Icons.lock_outline)
                          .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Password tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sign In',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum punya akun? ",
                        style: TextStyle(color: Colors.grey[700])),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.signup),
                      child: const Text('Daftar',
                          style: TextStyle(
                              color: primaryBlue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF2962FF), width: 2)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
