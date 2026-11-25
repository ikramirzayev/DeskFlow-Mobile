import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/router.dart';
import '../models/salon.dart';
import '../services/api_service.dart';
import '../services/salon_service.dart';

/// Yönetici için salon listesi: ekle, düzenle, sil.
class SalonYonetimScreen extends StatefulWidget {
  const SalonYonetimScreen({super.key});

  @override
  State<SalonYonetimScreen> createState() => _SalonYonetimScreenState();
}

class _SalonYonetimScreenState extends State<SalonYonetimScreen> {
  late final SalonService _servis;
  List<Salon> _salonlar = [];
  bool _yukleniyor = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _servis = SalonService(context.read<ApiService>());
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final liste = await _servis.listele();
      if (!mounted) return;
      setState(() => _salonlar = liste);
    } catch (e) {
      if (!mounted) return;
      setState(() => _hata = e.toString());
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  /// Form ekranı kayıt yaparsa true döner; o zaman liste yenilenir.
  Future<void> _formuAc(String adres, {Salon? salon}) async {
    final kaydedildi = await context.push<bool>(adres, extra: salon);
    if (kaydedildi == true) await _yukle();
  }

  Future<void> _sil(Salon salon) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salonu sil'),
        content: Text(
          '"${salon.ad}" salonu ve ${salon.masaSayisi} masası silinecek. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (onay != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _servis.sil(salon.id);
      messenger.showSnackBar(
        SnackBar(content: Text('"${salon.ad}" silindi.')),
      );
      await _yukle();
    } catch (e) {
      // Örn. 409: salonun rezervasyonları olduğu için silinemez.
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salon Yönetimi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _formuAc(Adresler.salonEkle),
        icon: const Icon(Icons.add),
        label: const Text('Salon ekle'),
      ),
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
              children: const [
                SizedBox(height: 200),
                Center(child: Text('Henüz salon yok. Sağ alttan ekleyin.')),
              ],
            )
          : ListView.builder(
              // FAB son satırın üstünü kapatmasın.
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: _salonlar.length,
              itemBuilder: (context, i) {
                final salon = _salonlar[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(salon.ad),
                    subtitle: Text(
                      'Kat ${salon.kat} · ${salon.acilisSaati}–${salon.kapanisSaati} · '
                      '${salon.masaSayisi} masa${salon.aktifMi ? '' : ' · Kapalı'}',
                    ),
                    onTap: () =>
                        _formuAc(Adresler.salonDuzenle(salon.id), salon: salon),
                    trailing: IconButton(
                      tooltip: 'Sil',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _sil(salon),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
