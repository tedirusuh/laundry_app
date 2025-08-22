// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';

// Halaman ini sekarang bisa dibuat lebih sederhana atau dihapus jika tidak lagi diperlukan.
// Untuk saat ini, kita beri pesan placeholder.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin Lama'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Fungsi admin sekarang dapat diakses melalui Dashboard.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
