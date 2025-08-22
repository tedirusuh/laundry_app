// lib/screens/create_order_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/utils/constants.dart';
import 'package:app_laundry/screens/profile_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final String serviceTitle;
  final User user;
  const CreateOrderScreen(
      {super.key, required this.serviceTitle, required this.user});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  double _totalPrice = 0.0;
  double _pricePerItem = 0.0;
  // --- PERUBAHAN 1: Jadikan 'Bayar di Tempat (COD)' sebagai pilihan default ---
  String _selectedPaymentMethod = 'Bayar di Tempat (COD)';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setPriceBasedOnService();
    _weightController.addListener(_calculatePrice);

    _nameController.text = widget.user.name;
    _addressController.text = widget.user.address ?? '';
    _whatsappController.text = widget.user.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _weightController.removeListener(_calculatePrice);
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setPriceBasedOnService() {
    double price = 7000;
    switch (widget.serviceTitle.toLowerCase()) {
      case 'setrika':
        price = 5000;
        break;
      case 'satuan':
        price = 8000;
        break;
      case 'timbangan':
        price = 7000;
        break;
      case 'karpet':
        price = 10000;
        break;
      case 'sepatu':
        price = 25000;
        break;
    }
    setState(() => _pricePerItem = price);
  }

  void _calculatePrice() {
    final quantity = double.tryParse(_weightController.text) ?? 0;
    setState(() => _totalPrice = quantity * _pricePerItem);
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$API_URL/orders'),
        headers: {
          'Authorization': 'Bearer ${UserSession.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'title': widget.serviceTitle,
          'customer_name': _nameController.text,
          'customer_address': _addressController.text,
          'customer_whatsapp': _whatsappController.text,
          'price': _totalPrice,
          'weight': double.tryParse(_weightController.text) ?? 0,
          'notes': _notesController.text,
          'payment_method': _selectedPaymentMethod,
        }),
      );

      if (mounted) {
        final responseData = json.decode(response.body);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        } else {
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

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- PERUBAHAN 2: Daftar metode pembayaran diperbarui ---
    final List<String> paymentMethods = [
      'Bayar di Tempat (COD)',
      'Transfer via WhatsApp'
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Pesan Layanan ${widget.serviceTitle}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('Informasi Pengantaran',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _nameController,
                labelText: 'Nama Lengkap',
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _addressController,
                labelText: 'Alamat Lengkap',
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _whatsappController,
                labelText: 'Nomor WhatsApp',
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const Divider(height: 30),
            Text('Detail Pesanan',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _weightController,
              labelText: 'Berat (kg) atau Jumlah (pcs)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) =>
                  (double.tryParse(v!) == null || double.parse(v) <= 0)
                      ? 'Masukkan angka valid'
                      : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _notesController,
                labelText: 'Catatan (opsional)',
                maxLines: 3),
            const SizedBox(height: 20),
            Text('Harga: Rp ${_pricePerItem.toStringAsFixed(0)} / item',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Total Harga: Rp ${_totalPrice.toStringAsFixed(0)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // --- PERUBAHAN 3: Dropdown menggunakan daftar baru ---
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Metode Pembayaran',
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              items: paymentMethods
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedPaymentMethod = newValue);
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Konfirmasi Pesanan',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String labelText,
      TextInputType? keyboardType,
      int maxLines = 1,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      validator: validator,
    );
  }
}
