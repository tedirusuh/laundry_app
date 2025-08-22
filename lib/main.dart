// lib/main.dart
import 'package:app_laundry/app_routes.dart';
import 'package:app_laundry/providers/app_provider.dart';
import 'package:flutter/foundation.dart'; // 1. TAMBAHKAN IMPORT INI
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_laundry/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ================================================================
  // PERUBAHAN UTAMA ADA DI SINI
  // ================================================================
  // Inisialisasi Firebase dengan konfigurasi khusus untuk web
  await Firebase.initializeApp(
    // Gunakan 'options' hanya jika platform adalah web (kIsWeb)
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: "GANTI_DENGAN_API_KEY_ANDA",
            authDomain: "GANTI_DENGAN_AUTHDOMAIN_ANDA",
            projectId: "GANTI_DENGAN_PROJECTID_ANDA",
            storageBucket: "GANTI_DENGAN_STORAGEBUCKET_ANDA",
            messagingSenderId: "GANTI_DENGAN_MESSAGINGSENDERID_ANDA",
            appId: "GANTI_DENGAN_APPID_ANDA")
        : null,
  );
  // --- AKHIR PERUBAHAN ---

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Laundry App',
          theme: appProvider.currentTheme,
          locale: appProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
