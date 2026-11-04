import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// Profil sekmesi: bilgiler token ile GET /api/auth/ben isteğinden gelir.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _bilgiler;

  @override
  void initState() {
    super.initState();
    _bilgiler = context.read<AuthProvider>().authService.ben();
  }

  Future<void> _cikisYap() async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış yap'),
        content: const Text('Oturumu kapatmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
    if (onay != true || !mounted) return;
    await context.read<AuthProvider>().cikis();
  }

  @override
  Widget build(BuildContext context) {
    final oturum = context.watch<AuthProvider>().oturum;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bilgiler,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // API'ye ulaşılamazsa cihazdaki oturum bilgisiyle devam ederiz.
          final bilgi = snapshot.data;
          final adSoyad = bilgi != null
              ? '${bilgi['ad']} ${bilgi['soyad']}'
              : (oturum?.adSoyad ?? '');
          final email = bilgi?['email'] as String? ?? oturum?.email ?? '';
          final ogrenciNo = bilgi?['ogrenciNo'] as String?;
          final roller = (bilgi?['roller'] as List<dynamic>?)
                  ?.map((r) => r.toString())
                  .toList() ??
              oturum?.roller ??
              <String>[];
          final yonetici = roller.contains('Yonetici');

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                adSoyad,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Center(
                child: Chip(
                  label: Text(yonetici ? 'Yönetici' : 'Öğrenci'),
                  avatar: Icon(
                    yonetici ? Icons.admin_panel_settings : Icons.school,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('E-posta'),
                subtitle: Text(email),
              ),
              if (ogrenciNo != null && ogrenciNo.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Öğrenci No'),
                  subtitle: Text(ogrenciNo),
                ),
              if (snapshot.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _cikisYap,
                icon: const Icon(Icons.logout),
                label: const Text('Çıkış Yap'),
              ),
            ],
          );
        },
      ),
    );
  }
}
