import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/router.dart';
import '../models/masa.dart';
import '../models/salon.dart';
import '../services/api_service.dart';
import '../services/masa_service.dart';
import '../services/salon_service.dart';

/// Yönetici için masa listesi: salona göre filtrele, ekle, düzenle, sil.
class MasaYonetimScreen extends StatefulWidget {
  const MasaYonetimScreen({super.key});

  @override
  State<MasaYonetimScreen> createState() => _MasaYonetimScreenState();
}

class _MasaYonetimScreenState extends State<MasaYonetimScreen> {
  late final MasaService _servis;
  late final SalonService _salonServisi;
  List<Masa> _masalar = [];
  List<Salon> _salonlar = [];
  int? _secilenSalonId; // null = tüm salonlar
  bool _yukleniyor = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    final api = context.read<ApiService>();
    _servis = MasaService(api);
    _salonServisi = SalonService(api);
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final salonlar = await _salonServisi.listele();
      final masalar = await _servis.listele(salonId: _secilenSalonId);
      if (!mounted) return;
      setState(() {
        _salonlar = salonlar;
        _masalar = masalar;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _hata = e.toString());
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  /// Form ekranı kayıt yaparsa true döner; o zaman liste yenilenir.
  Future<void> _formuAc(String adres, {Masa? masa}) async {
    final kaydedildi = await context.push<bool>(adres, extra: masa);
    if (kaydedildi == true) await _yukle();
  }

  Future<void> _sil(Masa masa) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Masayı sil'),
        content: Text('"${masa.salonAd} · ${masa.masaNo}" masası silinecek. Emin misiniz?'),
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
      await _servis.sil(masa.id);
      messenger.showSnackBar(SnackBar(content: Text('${masa.masaNo} silindi.')));
      await _yukle();
    } catch (e) {
      // Örn. 409: masanın rezervasyonları olduğu için silinemez.
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masa Yönetimi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _formuAc(Adresler.masaEkle),
        icon: const Icon(Icons.add),
        label: const Text('Masa ekle'),
      ),
      body: _govde(),
    );
  }

  Widget _filtre() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: DropdownButtonFormField<int?>(
        initialValue: _secilenSalonId,
        decoration: const InputDecoration(labelText: 'Salon'),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('Tüm salonlar')),
          ..._salonlar.map(
            (s) => DropdownMenuItem<int?>(value: s.id, child: Text(s.ad)),
          ),
        ],
        onChanged: (deger) {
          setState(() => _secilenSalonId = deger);
          _yukle();
        },
      ),
    );
  }

  Widget _govde() {
    if (_yukleniyor && _masalar.isEmpty && _salonlar.isEmpty) {
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

    return Column(
      children: [
        _filtre(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _yukle,
            child: _masalar.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 160),
                      Center(child: Text('Masa yok. Sağ alttan ekleyin.')),
                    ],
                  )
                : ListView.builder(
                    // FAB son satırın üstünü kapatmasın.
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: _masalar.length,
                    itemBuilder: (context, i) {
                      final masa = _masalar[i];
                      final ozellikler = [
                        if (masa.prizliMi) 'Prizli',
                        if (masa.sessizBolgeMi) 'Sessiz',
                        if (!masa.aktifMi) 'Kapalı',
                      ];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('${masa.masaNo} · ${masa.salonAd}'),
                          subtitle: Text(
                            ozellikler.isEmpty ? 'Özellik yok' : ozellikler.join(' · '),
                          ),
                          onTap: () =>
                              _formuAc(Adresler.masaDuzenle(masa.id), masa: masa),
                          trailing: IconButton(
                            tooltip: 'Sil',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _sil(masa),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
