import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/salon.dart';
import '../models/salon_kaydet.dart';
import '../services/api_service.dart';
import '../services/salon_service.dart';

/// Salon ekleme ve düzenleme formu.
/// [salon] verilirse düzenleme modunda açılır. Kayıt başarılıysa ekran true ile kapanır.
class SalonFormScreen extends StatefulWidget {
  const SalonFormScreen({super.key, this.salon});

  final Salon? salon;

  @override
  State<SalonFormScreen> createState() => _SalonFormScreenState();
}

class _SalonFormScreenState extends State<SalonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ad;
  late final TextEditingController _kat;
  late final TextEditingController _kapasite;
  late TimeOfDay _acilis;
  late TimeOfDay _kapanis;
  late bool _aktif;
  String? _saatHatasi;
  bool _kaydediliyor = false;

  bool get _duzenlemeMi => widget.salon != null;

  @override
  void initState() {
    super.initState();
    final s = widget.salon;
    _ad = TextEditingController(text: s?.ad ?? '');
    _kat = TextEditingController(text: s?.kat.toString() ?? '0');
    _kapasite = TextEditingController(text: s?.kapasite.toString() ?? '');
    _acilis = SalonKaydet.saatOku(s?.acilisSaati ?? '') ??
        const TimeOfDay(hour: 8, minute: 0);
    _kapanis = SalonKaydet.saatOku(s?.kapanisSaati ?? '') ??
        const TimeOfDay(hour: 22, minute: 0);
    _aktif = s?.aktifMi ?? true;
  }

  @override
  void dispose() {
    _ad.dispose();
    _kat.dispose();
    _kapasite.dispose();
    super.dispose();
  }

  Future<void> _saatSec({required bool acilisMi}) async {
    final secilen = await showTimePicker(
      context: context,
      initialTime: acilisMi ? _acilis : _kapanis,
    );
    if (secilen == null) return;
    setState(() {
      if (acilisMi) {
        _acilis = secilen;
      } else {
        _kapanis = secilen;
      }
      _saatHatasi = null;
    });
  }

  Future<void> _kaydet() async {
    final formGecerli = _formKey.currentState!.validate();
    final saatHatasi = SalonDogrulama.saatler(_acilis, _kapanis);
    setState(() => _saatHatasi = saatHatasi);
    if (!formGecerli || saatHatasi != null) return;

    final istek = SalonKaydet(
      ad: _ad.text,
      kat: int.parse(_kat.text.trim()),
      kapasite: int.parse(_kapasite.text.trim()),
      acilisSaati: _acilis,
      kapanisSaati: _kapanis,
      aktifMi: _aktif,
    );

    setState(() => _kaydediliyor = true);
    final servis = SalonService(context.read<ApiService>());
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      if (_duzenlemeMi) {
        await servis.guncelle(widget.salon!.id, istek);
      } else {
        await servis.ekle(istek);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(_duzenlemeMi ? 'Salon güncellendi.' : 'Salon eklendi.')),
      );
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_duzenlemeMi ? 'Salonu Düzenle' : 'Yeni Salon')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _ad,
              decoration: const InputDecoration(labelText: 'Salon adı'),
              textInputAction: TextInputAction.next,
              validator: SalonDogrulama.ad,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _kat,
                    decoration: const InputDecoration(labelText: 'Kat'),
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    validator: SalonDogrulama.kat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _kapasite,
                    decoration: const InputDecoration(labelText: 'Kapasite'),
                    keyboardType: TextInputType.number,
                    validator: SalonDogrulama.kapasite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saatSec(acilisMi: true),
                    icon: const Icon(Icons.schedule),
                    label: Text('Açılış ${_acilis.format(context)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saatSec(acilisMi: false),
                    icon: const Icon(Icons.schedule),
                    label: Text('Kapanış ${_kapanis.format(context)}'),
                  ),
                ),
              ],
            ),
            if (_saatHatasi != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _saatHatasi!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Rezervasyona açık'),
              value: _aktif,
              onChanged: (deger) => setState(() => _aktif = deger),
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
