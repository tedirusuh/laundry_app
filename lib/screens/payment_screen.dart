import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentScreen extends StatelessWidget {
  final double totalAmount;
  const PaymentScreen({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    const String vaNumber = '88081234567890';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selesaikan Pembayaran Anda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('TOTAL TAGIHAN',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2962FF)),
                    ),
                    const Divider(height: 40),
                    Image.asset('assets/dana_logo.png',
                        height: 40), // Pastikan ada logo DANA
                    const SizedBox(height: 16),
                    const Text('Nomor Virtual Account DANA',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(vaNumber,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        IconButton(
                          icon:
                              const Icon(Icons.copy, color: Color(0xFF2962FF)),
                          onPressed: () {
                            Clipboard.setData(
                                const ClipboardData(text: vaNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Nomor VA berhasil disalin!')));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Kembali ke Home',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
