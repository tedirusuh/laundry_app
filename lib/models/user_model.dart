// lib/models/user_model.dart
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  String? profilePhotoUrl;
  // TAMBAHAN BARU
  String? phoneNumber;
  String? address;
  String? city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePhotoUrl,
    // TAMBAHAN BARU
    this.phoneNumber,
    this.address,
    this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      profilePhotoUrl: json['profile_photo_url'] as String?,
      // TAMBAHAN BARU: Ambil data dari JSON
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
    );
  }
}
