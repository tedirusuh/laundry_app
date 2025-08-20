// lib/screens/home_screen.dart
import 'package:app_laundry/models/laundry_model.dart';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/screens/laundry_detail_screen.dart';
import 'package:app_laundry/screens/orders_screen.dart';
import 'package:app_laundry/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- PASTIKAN IMPORT INI ADA

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreenContent(user: widget.user),
      OrdersScreen(user: widget.user),
      ProfileScreen(user: widget.user),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  final User user;
  const HomeScreenContent({super.key, required this.user});

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
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredLaundries = allLaundries
            .where((l) => l.title.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
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
      body: NestedScrollView(
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

  // --- FUNGSI PEMBAYARAN WHATSAPP ADA DI SINI ---
  Widget _buildPaymentSection(BuildContext context) {
    // GANTI DENGAN NOMOR WA ADMIN LAUNDRY ANDA
    const String adminPhoneNumber =
        '6283826905017'; // Awali dengan 62, tanpa + atau 0
    const double totalAmount = 35000;
    final String customerName = widget.user.name;

    // Pesan yang akan muncul otomatis di WhatsApp
    final String message =
        'Halo, saya ingin melakukan pembayaran laundry atas nama *$customerName* dengan total tagihan *Rp ${totalAmount.toStringAsFixed(0)}*.';

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
                  Text('Rp ${totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Buat URL untuk membuka WhatsApp
                final Uri whatsappUrl = Uri.parse(
                  'https://wa.me/$adminPhoneNumber?text=${Uri.encodeComponent(message)}',
                );

                // Coba buka URL
                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(whatsappUrl,
                      mode: LaunchMode.externalApplication);
                } else {
                  // Tampilkan pesan error jika WhatsApp tidak terinstal
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
                    ))),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(laundry.imagePath,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(child: Text("Gagal memuat gambar")))),
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
