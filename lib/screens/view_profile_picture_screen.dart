import 'package:flutter/material.dart';

class ViewProfilePictureScreen extends StatelessWidget {
  final String imageUrl;

  const ViewProfilePictureScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        // Gunakan Stack untuk menumpuk widget
        children: [
          // Widget 1: Gambar yang bisa di-zoom (memenuhi seluruh layar)
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                // Lebar dan tinggi diatur agar memenuhi layar
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.grey, size: 50));
                },
              ),
            ),
          ),
          // Widget 2: Tombol Kembali di pojok kiri atas, di atas foto
          Positioned(
            top: 40.0, // Jarak dari atas (bisa disesuaikan)
            left: 16.0, // Jarak dari kiri (bisa disesuaikan)
            child: SafeArea(
              // Menggunakan SafeArea agar tombol tidak terhalang status bar
              child: CircleAvatar(
                backgroundColor: Colors.black
                    .withOpacity(0.4), // Latar belakang semi-transparan
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
