import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/router.dart';

import '../models/rezervasyon.dart';
import '../services/api_service.dart';

class RezervasyonlarimScreen extends StatefulWidget {
  const RezervasyonlarimScreen({super.key});

  @override
  State<RezervasyonlarimScreen> createState() => _RezervasyonlarimScreenState();
}

class _RezervasyonlarimScreenState extends State<RezervasyonlarimScreen> {
  List<Rezervasyon> _kayitlar = [];
  bool _yukleniyor = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  /// spinner: false ise (aşağı çekerek yenileme) ekran spinner'a dönmez.
  Future<void> _yukle({bool spinner = true}) async {
    if (spinner) {
      setState(() {
        _yukleniyor = true;
        _hata = null;
      });
    }
    try {
      final cevap = await context.read<ApiService>().dio.get(
        '/api/rezervasyonlar/benim',
      );
      if (!mounted) return;
      setState(() {
        _kayitlar = (cevap.data as List<dynamic>)
            .map((e) => Rezervasyon.fromJson(e as Map<String, dynamic>))
            .toList();
        _hata = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _hata = ApiService.hataCevir(e).toString());
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _iptalEt(Rezervasyon r) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezervasyonu iptal et'),
        content: Text(
          '${r.salonAd}, masa ${r.masaNo}, '
          '${_tarihYaz(r.baslangic)} ${_saatYaz(r.baslangic)} rezervasyonu iptal edilsin mi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('İptal et'),
          ),
        ],
      ),
    );
    if (onay != true || !mounted) return;

    try {
      await context.read<ApiService>().dio.delete(
        '/api/rezervasyonlar/${r.id}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rezervasyon iptal edildi')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.hataCevir(e).toString())),
      );
    }
    // Başarıda da hatada da liste yenilenir; durum arada değişmiş olabilir.
    await _yukle(spinner: false);
  }

  /// Check-in penceresi: başlangıçtan 15 dk önce ile 15 dk sonra arası.
  bool _checkInZamaniMi(Rezervasyon r) {
    if (r.durum != 'Beklemede') return false;
    final simdi = DateTime.now();
    return !simdi.isBefore(r.baslangic.subtract(const Duration(minutes: 15))) &&
        !simdi.isAfter(r.baslangic.add(const Duration(minutes: 15)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rezervasyonlarım'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Yaklaşan'),
              Tab(text: 'Geçmiş'),
            ],
          ),
        ),
        body: _govde(),
      ),
    );
  }

  Widget _govde() {
    if (_yukleniyor) {
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

    final simdi = DateTime.now();
    final yaklasan =
        _kayitlar
            .where(
              (r) =>
                  (r.durum == 'Beklemede' || r.durum == 'Aktif') &&
                  r.bitis.isAfter(simdi),
            )
            .toList()
          ..sort((a, b) => a.baslangic.compareTo(b.baslangic));
    final gecmis = _kayitlar.where((r) => !yaklasan.contains(r)).toList();

    return TabBarView(
      children: [
        _liste(yaklasan, 'Yaklaşan rezervasyonunuz yok.'),
        _liste(gecmis, 'Geçmiş rezervasyonunuz yok.'),
      ],
    );
  }

  Widget _liste(List<Rezervasyon> kayitlar, String bosMesaj) {
    return RefreshIndicator(
      onRefresh: () => _yukle(spinner: false),
      child: kayitlar.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(child: Text(bosMesaj)),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              // Alttaki 88: Check-in butonu son kartı kapatmasın.
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: kayitlar.length,
              itemBuilder: (context, i) => _kart(kayitlar[i]),
            ),
    );
  }

  Widget _kart(Rezervasyon r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${r.salonAd} · Masa ${r.masaNo}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _durumRozeti(r.durum),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_tarihYaz(r.baslangic)}  ${_saatYaz(r.baslangic)} – ${_saatYaz(r.bitis)}',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (r.iptalEdilebilir)
                  TextButton(
                    onPressed: () => _iptalEt(r),
                    child: const Text('İptal'),
                  ),
                if (_checkInZamaniMi(r))
                  FilledButton(
                    onPressed: () async {
                      await context.push(Adresler.checkIn);
                      if (mounted) _yukle(spinner: false);
                    },
                    child: const Text('Check-in'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _durumRozeti(String durum) {
    final (yazi, renk) = switch (durum) {
      'Beklemede' => ('Beklemede', Colors.orange),
      'Aktif' => ('Aktif', Colors.green),
      'Tamamlandi' => ('Tamamlandı', Colors.blue),
      'Iptal' => ('İptal', Colors.red),
      'Gelmedi' => ('Gelmedi', Colors.grey),
      _ => (durum, Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: renk.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        yazi,
        style: TextStyle(
          color: renk.shade900,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _iki(int n) => n.toString().padLeft(2, '0');
String _tarihYaz(DateTime t) => '${_iki(t.day)}.${_iki(t.month)}.${t.year}';
String _saatYaz(DateTime t) => '${_iki(t.hour)}:${_iki(t.minute)}';
