// lib/providers/app_provider.dart
import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier {
  // --- LOGIKA TEMA ---
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // --- LOGIKA BAHASA ---
  Locale _locale = const Locale('id');
  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  // --- DEFINISI TEMA LENGKAP ---

  // TEMA TERANG (SESUAIKAN DENGAN WARNA AWAL ANDA)
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2962FF), // Warna biru utama Anda
    scaffoldBackgroundColor:
        const Color(0xFFE0F0FF), // Warna latar belakang biru muda Anda
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF2962FF),
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
        .copyWith(background: const Color(0xFFE0F0FF)),
  );

  // TEMA GELAP (GANTI WARNA DI BAWAH INI DENGAN DESAIN GELAP ANDA)
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    // GANTI DENGAN WARNA BIRU GELAP ANDA (untuk tombol, ikon aktif, dll.)
    primaryColor: const Color(0xFF448AFF),

    // GANTI DENGAN WARNA LATAR BELAKANG GELAP ANDA (misal: abu-abu sangat gelap)
    scaffoldBackgroundColor: const Color(0xFF1C2128),

    // GANTI DENGAN WARNA KARTU GELAP ANDA (misal: abu-abu sedikit lebih terang)
    cardColor: const Color(0xFF2D333B),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
          color: Colors.white), // Teks dan ikon AppBar menjadi putih
      titleTextStyle: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      // GANTI DENGAN WARNA NAVIGASI BAWAH GELAP ANDA
      backgroundColor: Color(0xFF22272E),
      selectedItemColor: Color(0xFF448AFF), // Warna ikon aktif
      unselectedItemColor: Colors.grey, // Warna ikon tidak aktif
    ),
    textTheme: const TextTheme(
      bodyLarge:
          TextStyle(color: Colors.white), // Warna teks utama menjadi putih
      bodyMedium: TextStyle(
          color: Colors.white70), // Warna teks sekunder menjadi putih pudar
    ),
    colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue, brightness: Brightness.dark)
        .copyWith(background: const Color(0xFF1C2128)),
  );
}
