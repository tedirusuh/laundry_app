// lib/screens/admin_orders_screen.dart
import 'dart:convert';
import 'package:app_laundry/models/order_model.dart';
import 'package:app_laundry/screens/profile_screen.dart';
import 'package:app_laundry/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminOrdersScreen extends StatefulWidget {
  final String? initialFilter;

  const AdminOrdersScreen({super.key, this.initialFilter});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  Future<void>? _ordersFuture;
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  String _currentFilter = 'Semua';

  // 1. TAMBAHKAN CONTROLLER UNTUK SEARCH BAR
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _currentFilter = widget.initialFilter!;
    }
    _ordersFuture = _fetchAllOrders();
    // Tambahkan listener untuk mendeteksi perubahan pada search bar
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/admin/orders'),
        headers: {
          'Authorization': 'Bearer ${UserSession.token}',
          'Accept': 'application/json',
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final List jsonResponse = json.decode(response.body);
          setState(() {
            _allOrders =
                jsonResponse.map((order) => Order.fromJson(order)).toList();
            _applyFilter();
          });
        } else {
          throw Exception('Gagal memuat pesanan.');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 2. PERBARUI FUNGSI FILTER UNTUK MENANGANI PENCARIAN
  void _applyFilter() {
    List<Order> tempOrders = [];
    // Filter berdasarkan status (dropdown) terlebih dahulu
    if (_currentFilter == 'Semua') {
      tempOrders = _allOrders;
    } else {
      tempOrders =
          _allOrders.where((order) => order.status == _currentFilter).toList();
    }

    // Kemudian, filter berdasarkan teks pencarian dari hasil di atas
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      _filteredOrders = tempOrders.where((order) {
        final titleMatch = order.title.toLowerCase().contains(query);
        final nameMatch = order.customerName.toLowerCase().contains(query);
        return titleMatch ||
            nameMatch; // Cari berdasarkan judul layanan atau nama pelanggan
      }).toList();
    } else {
      _filteredOrders =
          tempOrders; // Jika tidak ada query, tampilkan hasil filter status
    }
    setState(() {}); // Perbarui UI untuk menampilkan hasil filter
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    // ... (Fungsi ini tidak berubah)
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
        await _fetchAllOrders(); // Refresh data setelah update
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

  Color _getStatusColor(String status) {
    // ... (Fungsi ini tidak berubah)
    switch (status) {
      case 'Lunas':
        return Colors.purple;
      case 'Selesai':
        return Colors.green;
      case 'Diproses':
        return Colors.blue;
      case 'Dibatalkan':
        return Colors.red;
      case 'Menunggu Konfirmasi':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Pesanan Aktif')),
      body: RefreshIndicator(
        onRefresh: _fetchAllOrders,
        child: Column(
          // Gunakan Column untuk menempatkan search bar di atas list
          children: [
            // 3. TAMBAHKAN WIDGET SEARCH BAR DI SINI
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama pelanggan atau layanan...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
              ),
            ),
            // --- AKHIR SEARCH BAR ---

            Expanded(
              child: FutureBuilder(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _allOrders.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError && _allOrders.isEmpty) {
                    return Center(child: Text('Error: Gagal memuat data.'));
                  }
                  if (_allOrders.isEmpty) {
                    return const Center(
                        child: Text('Tidak ada pesanan aktif.'));
                  }
                  if (_filteredOrders.isEmpty) {
                    return Center(
                      child: Text(
                        _searchController.text.isNotEmpty
                            ? 'Pesanan tidak ditemukan.'
                            : 'Tidak ada pesanan dengan status ini.',
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    // ... (Fungsi ini tidak berubah dari kode Anda sebelumnya)
    final List<String> statusOptions = [
      'Menunggu Konfirmasi',
      'Diproses',
      'Selesai',
      'Lunas',
      'Dibatalkan',
      'Diarsipkan'
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan: ${order.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Pemesan: ${order.customerName}',
                style: TextStyle(color: Colors.grey.shade700)),
            const Divider(height: 20),
            Text('Total Harga: Rp ${order.price.toStringAsFixed(0)}'),
            Text('Berat/Jumlah: ${order.weight}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ubah Status:', style: TextStyle(fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: statusOptions.contains(order.status)
                          ? order.status
                          : null,
                      hint: Text('Pilih Status'),
                      icon: Icon(Icons.arrow_drop_down,
                          color: _getStatusColor(order.status)),
                      style: TextStyle(
                          color: _getStatusColor(order.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      onChanged: (String? newValue) {
                        if (newValue != null && newValue != order.status) {
                          _updateOrderStatus(order, newValue);
                        }
                      },
                      items: statusOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(color: Colors.black87)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
