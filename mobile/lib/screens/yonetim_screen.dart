import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router.dart';

/// Sadece yöneticilere görünen sekme.
class YonetimScreen extends StatelessWidget {
  const YonetimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yönetim')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _YonetimKarti(
            ikon: Icons.meeting_room_outlined,
            baslik: 'Salon Yönetimi',
            aciklama: 'Salon ekle, çalışma saatlerini ve kapasitesini düzenle.',
            onTap: () => context.push(Adresler.salonYonetimi),
          ),
          _YonetimKarti(
            ikon: Icons.event_seat_outlined,
            baslik: 'Masa Yönetimi',
            aciklama: 'Masa ekle; priz, sessiz bölge ve QR bilgisini düzenle.',
            onTap: () => context.push(Adresler.masaYonetimi),
          ),
        ],
      ),
    );
  }
}

class _YonetimKarti extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String aciklama;
  final VoidCallback onTap;

  const _YonetimKarti({
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(ikon, size: 32),
        title: Text(baslik),
        subtitle: Text(aciklama),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
