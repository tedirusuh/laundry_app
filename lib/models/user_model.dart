// lib/models/user_model.dart

// 1. TAMBAHKAN IMPORT INI UNTUK MENGAKSES API_URL
import 'package:app_laundry/utils/constants.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  String? profilePhotoPath; // 2. UBAH NAMA FIELD INI
  String? phoneNumber;
  String? address;
  String? city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePhotoPath, // 3. SESUAIKAN DI SINI
    this.phoneNumber,
    this.address,
    this.city,
  });

  // --- 4. TAMBAHKAN GETTER BARU UNTUK MEMPERBAIKI URL SECARA OTOMATIS ---
  String? get profilePhotoUrl {
    if (profilePhotoPath == null) {
      return null;
    }
    // Jika path sudah berisi http, gunakan langsung (menghindari duplikasi)
    if (profilePhotoPath!.startsWith('http')) {
      return profilePhotoPath;
    }
    // Jika belum, gabungkan dengan base URL dari API
    // Ganti 'localhost' dengan IP jika menjalankan di HP fisik
    final baseUrl = API_URL.replaceAll('/api', '');
    return '$baseUrl/storage/$profilePhotoPath';
  }
  // --- AKHIR GETTER BARU ---

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      // 5. PASTIKAN MENGAMBIL 'profile_photo_path' DARI JSON
      profilePhotoPath: json['profile_photo_path'] as String?,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
    );
  }
}
