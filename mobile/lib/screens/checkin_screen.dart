import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/check_in_sonucu.dart';
import '../services/api_service.dart';
import '../services/checkin_service.dart';

/// Masadaki QR kodu kamerayla okutup check-in yapar.
/// Emülatörde kamera düzgün çalışmadığı için kod elle de girilebilir.
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key, this.kameraAcik = true});

  /// Testlerde kamera eklentisi olmadığı için false verilir.
  final bool kameraAcik;

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kodKutusu = TextEditingController();
  late final CheckInService _servis;
  MobileScannerController? _kamera;

  bool _gonderiliyor = false;
  CheckInSonucu? _sonuc;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _servis = CheckInService(context.read<ApiService>());
    if (widget.kameraAcik) {
      // noDuplicates: kamera aynı kodu saniyede onlarca kez görür; tek sefer bildirilsin.
      _kamera = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
    }
  }

  @override
  void dispose() {
    _kamera?.dispose();
    _kodKutusu.dispose();
    super.dispose();
  }

  void _qrOkundu(BarcodeCapture yakalanan) {
    if (yakalanan.barcodes.isEmpty) return;
    final kod = yakalanan.barcodes.first.rawValue;
    if (kod == null || kod.trim().isEmpty) return;
    _kodKutusu.text = kod;
    _gonder(kod);
  }

  void _elleGonder() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _gonder(_kodKutusu.text);
  }

  Future<void> _gonder(String kod) async {
    // Bir istek sürerken yeni okuma ya da buton basışı yok sayılır.
    if (_gonderiliyor || _sonuc != null) return;

    setState(() {
      _gonderiliyor = true;
      _hata = null;
    });
    await _kameraKomutu(() => _kamera?.stop());

    try {
      final sonuc = await _servis.checkInYap(kod);
      if (!mounted) return;
      setState(() => _sonuc = sonuc);
    } catch (e) {
      if (!mounted) return;
      setState(() => _hata = e.toString());
    } finally {
      if (mounted) setState(() => _gonderiliyor = false);
    }
  }

  Future<void> _tekrarDene() async {
    setState(() {
      _sonuc = null;
      _hata = null;
      _kodKutusu.clear();
    });
    await _kameraKomutu(() => _kamera?.start());
  }

  /// Kamera izni verilmediyse ya da kamera hiç açılmadıysa start/stop hata fırlatabilir;
  /// bu durumda elle giriş çalışmaya devam etsin diye hatayı yutuyoruz.
  Future<void> _kameraKomutu(Future<void>? Function() komut) async {
    try {
      await komut();
    } catch (_) {
      // Kamera kullanılamıyor; elle giriş yeterli.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR ile Check-in')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_kamera != null && _sonuc == null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: MobileScanner(controller: _kamera, onDetect: _qrOkundu),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masanın üzerindeki QR kodu çerçeveye getirin.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
          if (_sonuc != null)
            _BasariKarti(sonuc: _sonuc!, onKapat: () => Navigator.of(context).maybePop())
          else
            _elleGirisFormu(),
          if (_hata != null) ...[
            const SizedBox(height: 16),
            _HataKarti(mesaj: _hata!, onTekrar: _tekrarDene),
          ],
        ],
      ),
    );
  }

  Widget _elleGirisFormu() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Kodu elle gir', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _kodKutusu,
            decoration: const InputDecoration(
              labelText: 'QR kod',
              hintText: 'DESKFLOW-S1-A1',
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _elleGonder(),
            validator: CheckInService.kodDogrula,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _gonderiliyor ? null : _elleGonder,
            child: _gonderiliyor
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Check-in yap'),
          ),
        ],
      ),
    );
  }
}

class _BasariKarti extends StatelessWidget {
  const _BasariKarti({required this.sonuc, required this.onKapat});

  final CheckInSonucu sonuc;
  final VoidCallback onKapat;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 12),
            Text('Check-in yapıldı', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${sonuc.salonAd} · Kat ${sonuc.kat}'),
            Text('Masa ${sonuc.masaNo} · ${sonuc.saatAraligi}'),
            const SizedBox(height: 16),
            FilledButton(onPressed: onKapat, child: const Text('Tamam')),
          ],
        ),
      ),
    );
  }
}

class _HataKarti extends StatelessWidget {
  const _HataKarti({required this.mesaj, required this.onTekrar});

  final String mesaj;
  final VoidCallback onTekrar;

  @override
  Widget build(BuildContext context) {
    final renk = Theme.of(context).colorScheme.error;
    return Card(
      color: renk.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: renk, size: 40),
            const SizedBox(height: 8),
            Text(mesaj, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onTekrar, child: const Text('Tekrar dene')),
          ],
        ),
      ),
    );
  }
}
