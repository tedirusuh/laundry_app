// lib/models/order_model.dart
class Order {
  final int id;
  final String title;
  final String customerName;
  final String status;
  final double price;
  final double weight;
  final String? customerAddress;
  final String? customerWhatsapp;
  final String? paymentMethod;
  final String? notes;

  Order({
    required this.id,
    required this.title,
    required this.customerName,
    required this.status,
    required this.price,
    required this.weight,
    this.customerAddress,
    this.customerWhatsapp,
    this.paymentMethod,
    this.notes,
  });

  // --- PERBAIKAN UTAMA ADA DI FUNGSI INI ---
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      // Ambil 'id' langsung sebagai integer, jangan di-parse
      id: json['id'] as int,
      title: json['title'],
      customerName: json['customer_name'],
      status: json['status'],
      // Ubah ke String dulu sebelum di-parse agar lebih aman
      price: double.parse(json['price'].toString()),
      weight: double.parse(json['weight'].toString()),
      customerAddress: json['customer_address'],
      customerWhatsapp: json['customer_whatsapp'],
      paymentMethod: json['payment_method'],
      notes: json['notes'],
    );
  }
}
