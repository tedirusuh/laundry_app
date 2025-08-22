// lib/screens/orders_screen.dart
import 'dart:convert';
import 'package:app_laundry/models/order_model.dart';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/screens/create_order_screen.dart';
import 'package:app_laundry/screens/profile_screen.dart';
import 'package:app_laundry/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Data class untuk item layanan agar lebih rapi
class ServiceItem {
  final String title;
  final String imagePath;
  final double imageSize;

  ServiceItem(this.title, this.imagePath, {this.imageSize = 30.0});
}

class OrdersScreen extends StatefulWidget {
  final User user;
  const OrdersScreen({super.key, required this.user});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> _ordersFuture;

  bool get isAdmin => widget.user.role == 'admin';

  // Daftar layanan dibuat di sini agar lebih mudah dikelola
  final List<ServiceItem> serviceItems = [
    ServiceItem('Setrika', 'assets/setrika.png'),
    ServiceItem('Satuan', 'assets/baju-removebg-preview.png'),
    ServiceItem('Timbangan', 'assets/Timbangan-removebg-preview (1).png',
        imageSize: 25.0),
    ServiceItem('Karpet', 'assets/karpet.png'),
    ServiceItem('Sepatu', 'assets/sepatu.png'),
  ];

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = isAdmin ? _fetchAllOrdersForAdmin() : _fetchMyOrders();
    });
  }

  Future<List<Order>> _fetchMyOrders() async {
    // ... (Fungsi ini tidak berubah)
    if (UserSession.token == null) return [];
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
      throw Exception('Gagal memuat pesanan dari server.');
    }
  }

  Future<List<Order>> _fetchAllOrdersForAdmin() async {
    // ... (Fungsi ini tidak berubah)
    if (UserSession.token == null) return [];
    final response = await http.get(
      Uri.parse('$API_URL/admin/orders'),
      headers: {
        'Authorization': 'Bearer ${UserSession.token}',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((order) => Order.fromJson(order)).toList();
    } else {
      throw Exception('Gagal memuat semua pesanan (Admin).');
    }
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    // ... (Fungsi ini tidak berubah)
    if (!isAdmin) return;
    try {
      final response = await http.post(
        Uri.parse('$API_URL/admin/orders/${order.id}/update-status'),
        headers: {
          'Authorization': 'Bearer ${UserSession.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': newStatus}),
      );
      if (mounted) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor:
                response.statusCode == 200 ? Colors.green : Colors.red,
          ),
        );
        _refreshOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _navigateToCreateOrder(String serviceTitle) async {
    // ... (Fungsi ini tidak berubah)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderScreen(
          serviceTitle: serviceTitle,
          user: widget.user,
        ),
      ),
    );
    if (result == true) {
      _refreshOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Semua Pesanan Pelanggan' : 'Layanan Kami'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshOrders(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              vertical: 20.0), // Padding diatur ulang
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PERUBAHAN 1: Mengganti Wrap dengan ListView horizontal ---
              SizedBox(
                height: 95, // Beri tinggi tetap untuk list horizontal
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: serviceItems.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemBuilder: (context, index) {
                    final item = serviceItems[index];
                    return _buildServiceCategory(context, item);
                  },
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // Sesuaikan padding
                child: Text(
                  isAdmin ? 'Pesanan Terbaru' : 'Pesanan Aktif',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Order>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingSkeleton();
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Text('Tidak ada pesanan aktif.',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    );
                  }
                  List<Order> orders = snapshot.data!;
                  // Bungkus ListView.builder dengan Padding
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(orders[index]);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCategory(BuildContext context, ServiceItem item) {
    // --- PERUBAHAN 2: Mengatur ulang ukuran item agar pas di list horizontal ---
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToCreateOrder(item.title),
          child: Container(
            width: 80, // Beri lebar tetap untuk setiap item
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(item.imagePath,
                    height: item.imageSize,
                    width: item.imageSize,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.red, size: 30)),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    // ... (Fungsi ini tidak berubah)
    final List<String> statusOptions = [
      'Menunggu Konfirmasi',
      'Diproses',
      'Lunas',
      'Selesai',
      'Dibatalkan'
    ];
    Color getStatusColor(String status) {
      switch (status) {
        case 'Selesai':
          return const Color.fromARGB(255, 18, 221, 126);
        case 'Diproses':
          return Colors.blue;
        case 'Lunas':
          return const Color.fromARGB(255, 6, 221, 103);
        case 'Dibatalkan':
          return Colors.red;
        default:
          return Colors.orange;
      }
    }

    Widget statusWidget = isAdmin
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: getStatusColor(order.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: order.status,
                icon: Icon(Icons.arrow_drop_down,
                    color: getStatusColor(order.status)),
                style: TextStyle(
                    color: getStatusColor(order.status),
                    fontWeight: FontWeight.bold),
                items: statusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) _updateOrderStatus(order, newValue);
                },
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: getStatusColor(order.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20)),
            child: Text(order.status,
                style: TextStyle(
                    color: getStatusColor(order.status),
                    fontWeight: FontWeight.bold)),
          );
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(order.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 8),
                  statusWidget,
                ],
              ),
              const SizedBox(height: 4),
              Text('Pemesan: ${order.customerName}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const Divider(height: 20),
              Text('Total Harga: Rp ${order.price.toStringAsFixed(0)}'),
              Text('Berat/Jumlah: ${order.weight}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    // ... (Fungsi ini tidak berubah)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(
            3,
            (index) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: 100,
                                height: 20,
                                color: Colors.grey.shade200),
                            Container(
                                width: 80,
                                height: 20,
                                color: Colors.grey.shade200),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                            width: 150,
                            height: 16,
                            color: Colors.grey.shade200),
                        const Divider(height: 20),
                        Container(
                            width: 200,
                            height: 16,
                            color: Colors.grey.shade200),
                        const SizedBox(height: 6),
                        Container(
                            width: 120,
                            height: 16,
                            color: Colors.grey.shade200),
                      ],
                    ),
                  ),
                )),
      ),
    );
  }
}
