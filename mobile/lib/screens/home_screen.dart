import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/salon.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Salon> _salonlar = [];
  bool _yukleniyor = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<List<Salon>> _salonlariGetir() async {
    try {
      final cevap = await context.read<ApiService>().dio.get('/api/salonlar');
      final liste = cevap.data as List<dynamic>;
      return liste
          .map((e) => Salon.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final liste = await _salonlariGetir();
      if (!mounted) return;
      setState(() => _salonlar = liste);
    } catch (e) {
      if (!mounted) return;
      setState(() => _hata = e.toString());
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DeskFlow')),
      body: _govde(),
    );
  }

  Widget _govde() {
    if (_yukleniyor && _salonlar.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hata != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_hata!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _yukle, child: const Text('Tekrar dene')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _yukle,
      child: _salonlar.isEmpty
          ? ListView(
              // Liste boşken de aşağı çekilebilsin diye ListView.
              children: const [
                SizedBox(height: 200),
                Center(child: Text('Henüz salon yok')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _salonlar.length,
              itemBuilder: (context, i) => _SalonKarti(salon: _salonlar[i]),
            ),
    );
  }
}

class _SalonKarti extends StatelessWidget {
  final Salon salon;

  const _SalonKarti({required this.salon});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(salon.ad, style: textTheme.titleMedium)),
                _Rozet(aktif: salon.aktifMi),
              ],
            ),
            const SizedBox(height: 8),
            Text('Kat: ${salon.kat}'),
            Text('Saat: ${salon.acilisSaati} – ${salon.kapanisSaati}'),
            Text('Masa sayısı: ${salon.masaSayisi}'),
          ],
        ),
      ),
    );
  }
}

class _Rozet extends StatelessWidget {
  final bool aktif;

  const _Rozet({required this.aktif});

  @override
  Widget build(BuildContext context) {
    final renk = aktif ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        aktif ? 'Açık' : 'Kapalı',
        style: TextStyle(color: renk, fontWeight: FontWeight.w600),
      ),
    );
  }
}
