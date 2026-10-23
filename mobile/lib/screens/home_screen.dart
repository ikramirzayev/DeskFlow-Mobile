import 'package:flutter/material.dart';

import '../core/config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('DeskFlow')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_seat, size: 72),
              const SizedBox(height: 16),
              Text('DeskFlow', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                'Kütüphane masanı bul, rezerve et, QR ile check-in yap.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'API: ${AppConfig.apiBaseUrl}',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
