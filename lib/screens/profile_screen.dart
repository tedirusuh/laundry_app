// lib/screens/profile_screen.dart
import 'dart:async';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/screens/admin_screen.dart';
import 'package:app_laundry/screens/edit_profile_screen.dart';
import 'package:app_laundry/screens/settings_screen.dart';
import 'package:app_laundry/screens/view_profile_picture_screen.dart';
import 'package:app_laundry/utils/session_manager.dart';
import 'package:app_laundry/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_laundry/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class UserSession {
  static String? token;
}

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _profileUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileUser = widget.user;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (UserSession.token == null) return;
    try {
      final response = await http.get(
        Uri.parse('$API_URL/user'),
        headers: {
          'Authorization': 'Bearer ${UserSession.token}',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200 && mounted) {
        final responseData = json.decode(response.body);
        setState(() {
          _profileUser = User.fromJson(responseData);
        });
        await SessionManager.saveSession(_profileUser, UserSession.token!);
      }
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    setState(() => _isLoading = true);
    var uri = Uri.parse('$API_URL/user/photo');
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer ${UserSession.token}',
        'Accept': 'application/json',
      });
    final bytes = await image.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes('photo', bytes,
        filename: image.name,
        contentType: MediaType('image', image.name.split('.').last));
    request.files.add(multipartFile);
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 && mounted) {
        await _fetchUserDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Foto profil berhasil diperbarui!'),
              backgroundColor: Colors.green),
        );
      } else if (mounted) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${responseData['message']}')),
        );
      }
    } catch (e) {
      // Error handling
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfileScreen(user: _profileUser)),
    );
    if (result == true) {
      _fetchUserDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: [
          Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_profileUser.profilePhotoUrl != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewProfilePictureScreen(
                                    imageUrl: _profileUser.profilePhotoUrl!)));
                      }
                    },
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _profileUser.profilePhotoUrl != null
                          ? NetworkImage(_profileUser.profilePhotoUrl!)
                          : null,
                      child: _profileUser.profilePhotoUrl == null
                          ? Icon(Icons.person,
                              size: 50, color: Colors.grey.shade600)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade800,
                        border: Border.all(width: 2, color: Colors.white),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.edit,
                                color: Colors.white, size: 16),
                        onPressed: _isLoading ? null : _pickAndUploadImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(_profileUser.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_profileUser.email,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 32),

          // --- KODE TOMBOL ADMIN DITEMPATKAN DI SINI ---
          // Tombol ini hanya akan muncul jika peran pengguna adalah 'admin'
          if (_profileUser.role == 'admin')
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminScreen()),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Buka Panel Admin'),
              ),
            ),

          _buildInfoCard(context, title: "Detail Informasi", children: [
            _buildInfoRow(
                icon: Icons.phone_android,
                label: "Nomor HP",
                value: _profileUser.phoneNumber ?? "Belum diisi"),
            _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: "Alamat",
                value: _profileUser.address ?? "Belum diisi"),
            _buildInfoRow(
                icon: Icons.business_outlined,
                label: "Kota",
                value: _profileUser.city ?? "Belum diisi"),
          ]),
          const SizedBox(height: 24),
          _buildInfoCard(context, children: [
            _buildMenuRow(
              icon: Icons.edit_outlined,
              label: "Edit Profile",
              onTap: _navigateToEditProfile,
            ),
            _buildMenuRow(
              icon: Icons.settings_outlined,
              label: "Pengaturan",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()));
              },
            ),
          ]),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await SessionManager.clearSession();
              UserSession.token = null;
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 28, 42, 243),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('LOGOUT',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {String? title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title != null) ...[
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
          ],
          ...children,
        ]),
      ),
    );
  }

  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  Widget _buildMenuRow(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue.shade800),
      title: Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
