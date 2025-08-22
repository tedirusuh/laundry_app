// lib/screens/home_screen.dart
import 'dart:convert';
import 'package:app_laundry/models/laundry_model.dart';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/screens/admin_dashboard_screen.dart'; // <-- Pastikan import ini ada
import 'package:app_laundry/screens/laundry_detail_screen.dart';
import 'package:app_laundry/screens/orders_screen.dart';
import 'package:app_laundry/screens/profile_screen.dart';
import 'package:app_laundry/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // State dan fungsi untuk tagihan dipindahkan ke sini
  double _totalBilling = 0.0;
  bool _isBillingLoading = true;

  @override
  void initState() {
    super.initState();
    // Hanya ambil data tagihan jika yang login bukan admin
    if (widget.user.role != 'admin') {
      _fetchUserBilling();
    }
  }

  Future<void> _fetchUserBilling() async {
    if (!mounted) return;
    setState(() => _isBillingLoading = true);

    if (UserSession.token == null) {
      if (mounted) setState(() => _isBillingLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$API_URL/user/billing-total'),
        headers: {
          'Authorization': 'Bearer ${UserSession.token}',
          'Accept': 'application/json',
        },
      );
      if (mounted) {
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            _totalBilling = (responseData['total_billing'] as num).toDouble();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching billing: $e");
    } finally {
      if (mounted) {
        setState(() => _isBillingLoading = false);
      }
    }
  }

  void _onItemTapped(int index) {
    // Muat ulang data tagihan hanya jika pengguna biasa menekan tab Home
    if (widget.user.role != 'admin' && index == 0) {
      _fetchUserBilling();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.user.role == 'admin';

    // Daftar halaman/tab untuk pengguna biasa
    final List<Widget> userWidgetOptions = <Widget>[
      HomeScreenContent(
        user: widget.user,
        totalBilling: _totalBilling,
        isBillingLoading: _isBillingLoading,
        onRefresh: _fetchUserBilling,
      ),
      OrdersScreen(user: widget.user),
      ProfileScreen(user: widget.user),
    ];

    // Daftar halaman/tab untuk admin
    final List<Widget> adminWidgetOptions = <Widget>[
      AdminDashboardScreen(
          user: widget.user), // Halaman pertama adalah Dashboard
      OrdersScreen(user: widget.user),
      ProfileScreen(user: widget.user),
    ];

    // Tentukan item Bottom Navigation Bar yang sesuai
    final List<BottomNavigationBarItem> navBarItems = [
      BottomNavigationBarItem(
        icon: Icon(isAdmin ? Icons.dashboard_outlined : Icons.home_outlined),
        activeIcon: Icon(isAdmin ? Icons.dashboard : Icons.home),
        label: isAdmin ? 'Dashboard' : 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.assignment_outlined),
        activeIcon: Icon(Icons.assignment),
        label: 'Pesanan',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    return Scaffold(
      body: Center(
        child: isAdmin
            ? adminWidgetOptions.elementAt(_selectedIndex)
            : userWidgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: navBarItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ================================================================
// KODE UNTUK TAMPILAN PENGGUNA BIASA (TIDAK PERLU DIUBAH)
// ================================================================
class HomeScreenContent extends StatefulWidget {
  final User user;
  final double totalBilling;
  final bool isBillingLoading;
  final Future<void> Function() onRefresh;

  const HomeScreenContent({
    super.key,
    required this.user,
    required this.totalBilling,
    required this.isBillingLoading,
    required this.onRefresh,
  });

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final List<Laundry> allLaundries = [
    Laundry(
        id: '1',
        title: 'Setrika',
        rating: 4.8,
        price: 5000,
        imagePath: 'assets/setrika.jpg',
        description:
            'Pakaian rapi dan wangi dengan setrika uap profesional. Cocok untuk pakaian sehari-hari dan kemeja kerja.'),
    Laundry(
        id: '2',
        title: 'Satuan',
        rating: 4.9,
        price: 8000,
        imagePath: 'assets/Baju contoh.jpg',
        description:
            'Cuci dan setrika per potong pakaian. Penanganan khusus untuk setiap jenis bahan.'),
    Laundry(
        id: '3',
        title: 'Timbangan',
        rating: 4.7,
        price: 7000,
        imagePath: 'assets/timbang.jpg',
        description:
            'Layanan cuci kiloan, solusi hemat untuk cucian menumpuk. Sudah termasuk cuci, kering, dan lipat.'),
    Laundry(
        id: '4',
        title: 'Karpet',
        rating: 4.6,
        price: 10000,
        imagePath: 'assets/Karpet.jpg',
        description:
            'Cuci karpet berbagai ukuran dengan mesin khusus. Menghilangkan debu, tungau, dan noda membandel.'),
    Laundry(
        id: '5',
        title: 'Sepatu',
        rating: 5.0,
        price: 25000,
        imagePath: 'assets/sepatu.jpg',
        description:
            'Deep cleaning untuk semua jenis sepatu (sneakers, kulit, kanvas). Membuat sepatu Anda tampak seperti baru.'),
  ];
  List<Laundry> filteredLaundries = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredLaundries = allLaundries;
    _searchController.addListener(_filterLaundries);
  }

  void _filterLaundries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredLaundries = allLaundries
          .where((l) => l.title.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLaundries);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildCustomAppBar(),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildPaymentSection(context)),
            ];
          },
          body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredLaundries.length,
            itemBuilder: (context, index) {
              final laundry = filteredLaundries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildLaundryCard(context, laundry),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat datang,',
                style: Theme.of(context).textTheme.bodyMedium),
            Text(widget.user.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari kiloan, setrika, sepatu...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none),
          ),
        ),
      );

  Widget _buildPaymentSection(BuildContext context) {
    if (widget.isBillingLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (widget.totalBilling <= 0) {
      return const SizedBox.shrink();
    }
    const String adminPhoneNumber = '6283826905017';
    final String customerName = widget.user.name;
    final String message =
        'Halo, saya ingin melakukan pembayaran laundry atas nama *$customerName* dengan total tagihan *Rp ${widget.totalBilling.toStringAsFixed(0)}*.';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Tagihan Anda',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Rp ${widget.totalBilling.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final Uri whatsappUrl = Uri.parse(
                  'https://wa.me/$adminPhoneNumber?text=${Uri.encodeComponent(message)}',
                );
                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(whatsappUrl,
                      mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Tidak bisa membuka WhatsApp.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Bayar'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLaundryCard(BuildContext context, Laundry laundry) =>
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LaundryDetailScreen(
              laundry: laundry,
              user: widget.user,
            ),
          ),
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                laundry.imagePath,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Center(child: Text("Gagal memuat gambar")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(laundry.title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(laundry.rating.toString(),
                                style: const TextStyle(fontSize: 15)),
                          ]),
                        ],
                      ),
                    ),
                    Text('Rp ${laundry.price}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor)),
                  ],
                ),
              )
            ],
          ),
        ),
      );
}
