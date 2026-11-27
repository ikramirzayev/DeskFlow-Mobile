import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/masa.dart';
import '../models/masa_kaydet.dart';
import '../models/salon.dart';
import '../services/api_service.dart';
import '../services/masa_service.dart';
import '../services/salon_service.dart';

/// Masa ekleme ve düzenleme formu.
/// [masa] verilirse düzenleme modunda açılır. Kayıt başarılıysa ekran true ile kapanır.
class MasaFormScreen extends StatefulWidget {
  const MasaFormScreen({super.key, this.masa});

  final Masa? masa;

  @override
  State<MasaFormScreen> createState() => _MasaFormScreenState();
}

class _MasaFormScreenState extends State<MasaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _masaNo;
  late final TextEditingController _x;
  late final TextEditingController _y;
  late bool _prizli;
  late bool _sessiz;
  late bool _aktif;
  int? _salonId;
  List<Salon> _salonlar = [];
  String? _salonHatasi;
  bool _salonlarYukleniyor = true;
  bool _kaydediliyor = false;

  bool get _duzenlemeMi => widget.masa != null;

  @override
  void initState() {
    super.initState();
    final m = widget.masa;
    _masaNo = TextEditingController(text: m?.masaNo ?? '');
    _x = TextEditingController(text: m == null ? '0' : m.x.toString());
    _y = TextEditingController(text: m == null ? '0' : m.y.toString());
    _prizli = m?.prizliMi ?? false;
    _sessiz = m?.sessizBolgeMi ?? false;
    _aktif = m?.aktifMi ?? true;
    _salonId = m?.salonId;
    _salonlariYukle();
  }

  @override
  void dispose() {
    _masaNo.dispose();
    _x.dispose();
    _y.dispose();
    super.dispose();
  }

  Future<void> _salonlariYukle() async {
    try {
      final liste = await SalonService(context.read<ApiService>()).listele();
      if (!mounted) return;
      setState(() {
        _salonlar = liste;
        // Düzenlenen masanın salonu listede yoksa seçimi temizle.
        if (_salonId != null && !liste.any((s) => s.id == _salonId)) {
          _salonId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _salonHatasi = e.toString());
    } finally {
      if (mounted) setState(() => _salonlarYukleniyor = false);
    }
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;

    final istek = MasaKaydet(
      masaNo: _masaNo.text,
      salonId: _salonId!,
      x: MasaDogrulama.koordinatOku(_x.text) ?? 0,
      y: MasaDogrulama.koordinatOku(_y.text) ?? 0,
      prizliMi: _prizli,
      sessizBolgeMi: _sessiz,
      aktifMi: _aktif,
    );

    setState(() => _kaydediliyor = true);
    final servis = MasaService(context.read<ApiService>());
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      if (_duzenlemeMi) {
        await servis.guncelle(widget.masa!.id, istek);
      } else {
        await servis.ekle(istek);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(_duzenlemeMi ? 'Masa güncellendi.' : 'Masa eklendi.')),
      );
      navigator.pop(true);
    } catch (e) {
      // Örn. 400: aynı salonda aynı masa numarası var.
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_duzenlemeMi ? 'Masayı Düzenle' : 'Yeni Masa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_salonlarYukleniyor)
              const Center(child: CircularProgressIndicator())
            else if (_salonHatasi != null)
              Text(
                _salonHatasi!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else
              DropdownButtonFormField<int>(
                initialValue: _salonId,
                decoration: const InputDecoration(labelText: 'Salon'),
                items: _salonlar
                    .map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.ad)))
                    .toList(),
                onChanged: (deger) => setState(() => _salonId = deger),
                validator: (deger) => deger == null ? 'Salon seçin.' : null,
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _masaNo,
              decoration: const InputDecoration(labelText: 'Masa numarası (örn. M03)'),
              textInputAction: TextInputAction.next,
              validator: MasaDogrulama.masaNo,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _x,
                    decoration: const InputDecoration(labelText: 'X konumu'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: MasaDogrulama.koordinat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _y,
                    decoration: const InputDecoration(labelText: 'Y konumu'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: MasaDogrulama.koordinat,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Prizli'),
              value: _prizli,
              onChanged: (deger) => setState(() => _prizli = deger),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sessiz bölge'),
              value: _sessiz,
              onChanged: (deger) => setState(() => _sessiz = deger),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Rezervasyona açık'),
              value: _aktif,
              onChanged: (deger) => setState(() => _aktif = deger),
            ),
            if (!_duzenlemeMi)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('QR kod otomatik üretilir (DESKFLOW-S{salon}-{masa no}).'),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _kaydediliyor ? null : _kaydet,
              child: _kaydediliyor
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
