// lib/screens/admin_dashboard_screen.dart
import 'dart:convert';
import 'package:app_laundry/models/order_model.dart';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/screens/admin_archived_orders_screen.dart';
import 'package:app_laundry/screens/admin_orders_screen.dart';
import 'package:app_laundry/screens/profile_screen.dart';
import 'package:app_laundry/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Model untuk menampung data dashboard
class DashboardStats {
  final int totalOrders;
  final int pendingOrders;
  final int processingOrders;
  final double totalRevenue;
  final List<Order> recentOrders;

  DashboardStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.processingOrders,
    required this.totalRevenue,
    required this.recentOrders,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    var orderList = json['recent_orders'] as List;
    List<Order> orders = orderList.map((i) => Order.fromJson(i)).toList();
    return DashboardStats(
      totalOrders: json['total_orders'],
      pendingOrders: json['pending_orders'],
      processingOrders: json['processing_orders'],
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      recentOrders: orders,
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  final User user;
  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Future<DashboardStats>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchDashboardStats();
  }

  Future<DashboardStats> _fetchDashboardStats() async {
    final response = await http.get(
      Uri.parse('$API_URL/admin/dashboard'),
      headers: {
        'Authorization': 'Bearer ${UserSession.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat data dashboard.');
    }
  }

  void _navigateToOrders({String? filter}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminOrdersScreen(initialFilter: filter),
      ),
    ).then((_) {
      // Refresh dashboard setelah kembali dari halaman order
      setState(() {
        _statsFuture = _fetchDashboardStats();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _statsFuture = _fetchDashboardStats();
          });
        },
        child: FutureBuilder<DashboardStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("Data tidak ditemukan."));
            }

            final stats = snapshot.data!;
            final currencyFormatter = NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                        'Total Pesanan',
                        stats.totalOrders.toString(),
                        Icons.shopping_cart_outlined,
                        Colors.blue,
                        onTap: () => _navigateToOrders(filter: 'Semua')),
                    _buildStatCard(
                        'Pesanan Baru',
                        stats.pendingOrders.toString(),
                        Icons.new_releases_outlined,
                        Colors.orange,
                        onTap: () =>
                            _navigateToOrders(filter: 'Menunggu Konfirmasi')),
                    _buildStatCard(
                        'Sedang Diproses',
                        stats.processingOrders.toString(),
                        Icons.hourglass_top_outlined,
                        Colors.purple,
                        onTap: () => _navigateToOrders(filter: 'Diproses')),
                    _buildStatCard(
                        'Total Pendapatan',
                        currencyFormatter.format(stats.totalRevenue),
                        Icons.attach_money_outlined,
                        Colors.green,
                        onTap: () => _navigateToOrders(filter: 'Lunas')),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Aksi Cepat',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _navigateToOrders(),
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Kelola Pesanan Aktif'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // --- PERUBAHAN UTAMA: TOMBOL INI SEKARANG UNTUK NAVIGASI ---
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AdminArchivedOrdersScreen()));
                  },
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Lihat Arsip & Pesanan Batal'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                // --- AKHIR PERUBAHAN ---

                const SizedBox(height: 24),
                Text('Pesanan Terbaru',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (stats.recentOrders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: Text('Belum ada pesanan terbaru.')),
                  )
                else
                  ...stats.recentOrders
                      .map((order) => _buildRecentOrderTile(order))
                      .toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {required VoidCallback onTap}) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 32, color: color),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(title, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrderTile(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToOrders(),
        child: ListTile(
          title: Text(order.title),
          subtitle: Text('Pemesan: ${order.customerName}'),
          trailing: Text(
            order.status,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.orange.shade700),
          ),
        ),
      ),
    );
  }
}
