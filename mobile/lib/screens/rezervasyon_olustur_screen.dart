import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';

import 'package:flutter/material.dart';

class RezervasyonOlusturScreen extends StatefulWidget {
  final int masaId;

  const RezervasyonOlusturScreen({super.key, required this.masaId});

  @override
  State<RezervasyonOlusturScreen> createState() =>
      _RezervasyonOlusturScreenState();
}

class _RezervasyonOlusturScreenState extends State<RezervasyonOlusturScreen> {
  DateTime? _tarih;
  TimeOfDay? _baslangic;
  TimeOfDay? _bitis;
  bool _gonderiliyor = false;

  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
  }

  /// Gönderilmeden önce ekranda yapılan kontrol. Hata yoksa null döner.
  String? _kontrolEt(DateTime? baslangic, DateTime? bitis) {
    if (baslangic == null || bitis == null) {
      return 'Tarih ve saatleri seçin.';
    }
    if (!bitis.isAfter(baslangic)) {
      return 'Bitiş saati başlangıçtan sonra olmalı.';
    }
    final sure = bitis.difference(baslangic);
    if (sure < const Duration(minutes: 30)) {
      return 'Rezervasyon en az 30 dakika olmalı.';
    }
    if (sure > const Duration(hours: 4)) {
      return 'Rezervasyon en fazla 4 saat olabilir.';
    }
    return null;
  }

  Future<void> _gonder() async {
    final t = _tarih;
    final b = _baslangic;
    final s = _bitis;
    final baslangic = (t == null || b == null)
        ? null
        : DateTime(t.year, t.month, t.day, b.hour, b.minute);
    final bitis = (t == null || s == null)
        ? null
        : DateTime(t.year, t.month, t.day, s.hour, s.minute);

    final hata = _kontrolEt(baslangic, bitis);
    if (hata != null) {
      _mesajGoster(hata);
      return;
    }

    setState(() => _gonderiliyor = true);
    try {
      await context.read<ApiService>().dio.post(
        '/api/rezervasyonlar',
        data: {
          'masaId': widget.masaId,
          'baslangic': baslangic!.toIso8601String(),
          'bitis': bitis!.toIso8601String(),
        },
      );
      if (!mounted) return;
      _mesajGoster('Rezervasyon oluşturuldu');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      _mesajGoster(ApiService.hataCevir(e).toString());
    } finally {
      if (mounted) setState(() => _gonderiliyor = false);
    }
  }

  Future<void> _tarihSec() async {
    final bugun = DateTime.now();
    final secilen = await showDatePicker(
      context: context,
      initialDate: _tarih ?? bugun,
      firstDate: bugun,
      lastDate: bugun.add(const Duration(days: 7)),
    );
    if (secilen != null) setState(() => _tarih = secilen);
  }

  Future<void> _saatSec({required bool baslangicMi}) async {
    final secilen = await showTimePicker(
      context: context,
      initialTime: (baslangicMi ? _baslangic : _bitis) ?? TimeOfDay.now(),
    );
    if (secilen == null) return;
    setState(() {
      if (baslangicMi) {
        _baslangic = secilen;
      } else {
        _bitis = secilen;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = _tarih;
    return Scaffold(
      appBar: AppBar(title: const Text('Rezervasyon Yap')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Tarih'),
            subtitle: Text(
              t == null
                  ? 'Seçilmedi'
                  : '${t.day.toString().padLeft(2, '0')}.${t.month.toString().padLeft(2, '0')}.${t.year}',
            ),
            onTap: _tarihSec,
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Başlangıç saati'),
            subtitle: Text(_baslangic?.format(context) ?? 'Seçilmedi'),
            onTap: () => _saatSec(baslangicMi: true),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Bitiş saati'),
            subtitle: Text(_bitis?.format(context) ?? 'Seçilmedi'),
            onTap: () => _saatSec(baslangicMi: false),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _gonderiliyor ? null : _gonder,
            child: _gonderiliyor
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Rezervasyon Yap'),
          ),
        ],
      ),
    );
  }
}
