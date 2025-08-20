// lib/screens/edit_profile_screen.dart
import 'dart:convert';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/screens/profile_screen.dart';
import 'package:app_laundry/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _addressController = TextEditingController(text: widget.user.address);
    _cityController = TextEditingController(text: widget.user.city);
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$API_URL/user/update-details'),
        headers: {
          'Authorization': 'Bearer ${UserSession.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text,
          'phone_number': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
        }),
      );

      if (context.mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profil berhasil disimpan!'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        } else {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Gagal: ${responseData['message'] ?? 'Terjadi kesalahan'}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal terhubung ke server.')),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- PERUBAHAN: Hapus backgroundColor agar mengikuti tema ---
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildTextField(controller: _nameController, label: 'Nama Lengkap'),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _phoneController,
              label: 'Nomor HP',
              keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildTextField(controller: _addressController, label: 'Alamat'),
          const SizedBox(height: 16),
          _buildTextField(controller: _cityController, label: 'Kota'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              // --- PERUBAHAN: Gunakan warna dari tema ---
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('SIMPAN PERUBAHAN',
                    style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        // --- PERUBAHAN: Gunakan warna kartu dari tema ---
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
