// lib/screens/admin_archived_orders_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_laundry/models/order_model.dart';
import 'package:app_laundry/utils/constants.dart';
import 'package:app_laundry/screens/profile_screen.dart';

class AdminArchivedOrdersScreen extends StatefulWidget {
  const AdminArchivedOrdersScreen({super.key});

  @override
  State<AdminArchivedOrdersScreen> createState() =>
      _AdminArchivedOrdersScreenState();
}

class _AdminArchivedOrdersScreenState extends State<AdminArchivedOrdersScreen> {
  Future<List<Order>>? _archivedOrdersFuture;

  @override
  void initState() {
    super.initState();
    _refreshArchivedOrders();
  }

  Future<void> _refreshArchivedOrders() async {
    setState(() {
      _archivedOrdersFuture = _fetchArchivedOrders();
    });
  }

  Future<List<Order>> _fetchArchivedOrders() async {
    final response = await http.get(
      Uri.parse('$API_URL/admin/orders/archived'),
      headers: {
        'Authorization': 'Bearer ${UserSession.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body);
      return jsonResponse.map((order) => Order.fromJson(order)).toList();
    } else {
      throw Exception('Gagal memuat pesanan yang diarsipkan.');
    }
  }

  Future<void> _deleteOrder(int orderId) async {
    try {
      final response = await http.delete(
        Uri.parse('$API_URL/admin/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer ${UserSession.token}',
          'Accept': 'application/json',
        },
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
        if (response.statusCode == 200) {
          _refreshArchivedOrders();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
              'Apakah Anda yakin ingin menghapus pesanan "${order.title}" oleh ${order.customerName} secara permanen? Aksi ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteOrder(order.id);
                Navigator.of(ctx).pop();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arsip & Pesanan Batal')),
      body: RefreshIndicator(
        onRefresh: _refreshArchivedOrders,
        child: FutureBuilder<List<Order>>(
          future: _archivedOrdersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('Tidak ada pesanan yang diarsipkan.'));
            }
            final orders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildArchivedOrderCard(orders[index]);
              },
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET BARU YANG LEBIH DETAIL DAN MODERN ---
  Widget _buildArchivedOrderCard(Order order) {
    bool isCancelled = order.status == 'Dibatalkan';
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isCancelled ? Colors.red.shade200 : Colors.grey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
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
                    color: isCancelled
                        ? Colors.red.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: isCancelled ? Colors.red : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pemesan: ${order.customerName}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            if (order.customerWhatsapp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'WA: ${order.customerWhatsapp}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ),
            const Divider(height: 20),
            Text('Total Harga: Rp ${order.price.toStringAsFixed(0)}'),
            Text('Berat/Jumlah: ${order.weight}'),
            if (order.notes != null && order.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Catatan: ${order.notes}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_forever_outlined,
                      color: Colors.red),
                  tooltip: 'Hapus Permanen',
                  onPressed: () => _showDeleteConfirmation(context, order),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
