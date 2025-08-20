// lib/screens/orders_screen.dart
import 'dart:convert';
import 'package:app_laundry/models/order_model.dart';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/screens/create_order_screen.dart';
import 'package:app_laundry/screens/profile_screen.dart';
import 'package:app_laundry/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersScreen extends StatefulWidget {
  final User user;
  const OrdersScreen({super.key, required this.user});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  // Fungsi untuk mengambil data pesanan dari server Laravel
  Future<List<Order>> _fetchOrders() async {
    if (UserSession.token == null) {
      // Jika pengguna belum login, kembalikan list kosong
      return [];
    }

    final response = await http.get(
      Uri.parse('$API_URL/orders'),
      headers: {
        'Authorization': 'Bearer ${UserSession.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((order) => Order.fromJson(order)).toList();
    } else {
      // Jika gagal, lemparkan pesan error yang akan ditangkap oleh FutureBuilder
      throw Exception('Gagal memuat pesanan dari server.');
    }
  }

  // Fungsi untuk pindah ke halaman buat pesanan dan me-refresh setelahnya
  void _navigateToCreateOrder(String serviceTitle) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderScreen(
          serviceTitle: serviceTitle,
          user: widget.user,
        ),
      ),
    );

    // Jika halaman create order mengembalikan 'true', refresh daftar pesanan
    if (result == true) {
      setState(() {
        _ordersFuture = _fetchOrders();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan Kami'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _ordersFuture = _fetchOrders();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildServiceCategory(
                      context, 'Setrika', 'assets/setrika.png',
                      size: 25),
                  _buildServiceCategory(
                      context, 'Satuan', 'assets/baju-removebg-preview.png',
                      size: 25),
                  _buildServiceCategory(context, 'Timbangan',
                      'assets/Timbangan-removebg-preview (1).png',
                      size: 20),
                  _buildServiceCategory(context, 'Karpet', 'assets/karpet.png',
                      size: 25),
                  _buildServiceCategory(context, 'Sepatu', 'assets/sepatu.png',
                      size: 25),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  'Pesanan Aktif',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 22),
                ),
              ),
              const SizedBox(height: 12),

              // Widget untuk menampilkan daftar pesanan secara dinamis
              FutureBuilder<List<Order>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Anda belum memiliki pesanan aktif.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    List<Order> orders = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(orders[index]);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk membuat tombol kategori layanan
  Widget _buildServiceCategory(
      BuildContext context, String title, String imagePath,
      {double size = 45.0}) {
    return GestureDetector(
      onTap: () => _navigateToCreateOrder(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath,
                height: size,
                width: size,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.red, size: 40)),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan kartu pesanan
  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Menampilkan Nama Pemesan
            Text(
              'Pemesan: ${order.customerName}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const Divider(height: 20),
            Text('Total Harga: Rp ${order.price.toStringAsFixed(0)}'),
            const SizedBox(height: 4),
            Text('Berat/Jumlah: ${order.weight}'),
          ],
        ),
      ),
    );
  }
}
