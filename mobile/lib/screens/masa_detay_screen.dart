import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/masa.dart';
import '../services/api_service.dart';

class MasaDetayScreen extends StatefulWidget {
  final int masaId;

  const MasaDetayScreen({super.key, required this.masaId});

  @override
  State<MasaDetayScreen> createState() => _MasaDetayScreenState();
}

class _MasaDetayScreenState extends State<MasaDetayScreen> {
  Masa? _masa;
  bool _yukleniyor = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final cevap = await context.read<ApiService>().dio.get(
        '/api/masalar/${widget.masaId}',
      );
      if (!mounted) return;
      setState(() => _masa = Masa.fromJson(cevap.data as Map<String, dynamic>));
    } catch (e) {
      if (!mounted) return;
      setState(() => _hata = ApiService.hataCevir(e).toString());
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masa Detayı')),
      body: _govde(),
    );
  }

  Widget _govde() {
    if (_yukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }

    final masa = _masa;
    if (_hata != null || masa == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_hata ?? 'Masa bulunamadı.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _yukle, child: const Text('Tekrar dene')),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Masa ${masa.masaNo}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.meeting_room_outlined),
                title: const Text('Salon'),
                subtitle: Text(masa.salonAd),
              ),
              ListTile(
                leading: const Icon(Icons.bolt),
                title: const Text('Priz'),
                subtitle: Text(masa.prizliMi ? 'Var' : 'Yok'),
              ),
              ListTile(
                leading: const Icon(Icons.volume_off),
                title: const Text('Sessiz bölge'),
                subtitle: Text(masa.sessizBolgeMi ? 'Evet' : 'Hayır'),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rezervasyon 5. haftada eklenecek'),
                    ),
                  );
                },
                child: const Text('Rezerve et'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
