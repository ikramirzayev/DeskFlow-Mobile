import 'package:flutter/material.dart';

/// Henüz yapılmamış ekranların yerine geçici olarak gösterilir.
class GeciciEkran extends StatelessWidget {
  final String baslik;
  final String mesaj;

  const GeciciEkran({super.key, required this.baslik, required this.mesaj});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(baslik)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction, size: 48),
              const SizedBox(height: 16),
              Text(mesaj, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
