// lib/main.dart
import 'package:app_laundry/app_routes.dart';
import 'package:app_laundry/providers/app_provider.dart'; // <-- Pastikan import ini benar
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_laundry/l10n/app_localizations.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(), // <-- Gunakan AppProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      // <-- Dengarkan perubahan dari AppProvider
      builder: (context, appProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Laundry App',
          theme: appProvider.currentTheme, // <-- Gunakan tema dari provider
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
