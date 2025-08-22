// lib/screens/laundry_detail_screen.dart
import 'package:app_laundry/models/laundry_model.dart';
import 'package:app_laundry/models/user_model.dart';
import 'package:app_laundry/screens/create_order_screen.dart';
import 'package:flutter/material.dart';

class LaundryDetailScreen extends StatelessWidget {
  final Laundry laundry;
  final User user;
  const LaundryDetailScreen(
      {super.key, required this.laundry, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              // --- PERUBAHAN ADA DI SINI ---
              // Properti 'title' dihapus dari sini untuk menghilangkan teks
              background: Image.asset(
                laundry.imagePath,
                fit: BoxFit.cover,
                color:
                    const Color.fromARGB(255, 255, 254, 254).withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Harga per item',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[700])),
                      Text('Rp ${laundry.price}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2962FF))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(laundry.rating.toString(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(' (25 ulasan)',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text('Deskripsi',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    laundry.description,
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey[800], height: 1.5),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CreateOrderScreen(
                          serviceTitle: laundry.title,
                          user: user,
                        )));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2962FF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Pesan Sekarang',
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
