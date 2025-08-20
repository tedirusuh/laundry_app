// lib/screens/settings_screen.dart
import 'package:app_laundry/providers/app_provider.dart';
import 'package:app_laundry/screens/change_email_screen.dart';
import 'package:app_laundry/screens/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_laundry/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _showLanguageDialog(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.bahasa),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Indonesia'),
                onTap: () {
                  appProvider.setLocale(const Locale('id'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  appProvider.setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pengaturan),
      ),
      body: ListView(
        children: [
          Consumer<AppProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text(l10n.modeGelap),
                value: themeProvider.isDarkMode,
                onChanged: (bool value) => themeProvider.toggleTheme(),
                secondary: const Icon(Icons.dark_mode_outlined),
                // --- TAMBAHAN: Samakan warna aktif ---
                activeColor: Theme.of(context).primaryColor,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(l10n.gantiEmail),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangeEmailScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.gantiPassword),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n.notifikasi),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            // --- TAMBAHAN: Samakan warna aktif ---
            activeColor: Theme.of(context).primaryColor,
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.bahasa),
            onTap: () => _showLanguageDialog(context),
          ),
        ],
      ),
    );
  }
}
