import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/masa.dart';
import '../services/api_service.dart';

import 'package:go_router/go_router.dart';

class MasaListScreen extends StatefulWidget {
  final int salonId;

  const MasaListScreen({super.key, required this.salonId});

  @override
  State<MasaListScreen> createState() => _MasaListScreenState();
}

class _MasaListScreenState extends State<MasaListScreen> {
  List<Masa> _masalar = [];
  bool _yukleniyor = true;
  String? _hata;
  bool _prizli = false;
  bool _sessiz = false;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<List<Masa>> _masalariGetir() async {
    try {
      final cevap = await context.read<ApiService>().dio.get(
        '/api/masalar',
        queryParameters: {
          'salonId': widget.salonId,
          if (_prizli) 'prizli': true,
          if (_sessiz) 'sessiz': true,
        },
      );
      final liste = cevap.data as List<dynamic>;
      return liste
          .map((e) => Masa.fromJson(e as Map<String, dynamic>))
          .where((m) => m.aktifMi)
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
      final liste = await _masalariGetir();
      if (!mounted) return;
      setState(() => _masalar = liste);
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
      appBar: AppBar(title: const Text('Masalar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Prizli'),
                  selected: _prizli,
                  onSelected: (secili) {
                    setState(() {
                      _prizli = secili;
                      _masalar = [];
                    });
                    _yukle();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Sessiz'),
                  selected: _sessiz,
                  onSelected: (secili) {
                    setState(() {
                      _sessiz = secili;
                      _masalar = [];
                    });
                    _yukle();
                  },
                ),
              ],
            ),
          ),
          Expanded(child: _govde()),
        ],
      ),
    );
  }

  Widget _govde() {
    if (_yukleniyor && _masalar.isEmpty) {
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
      child: _masalar.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text('Bu filtrelere uygun masa yok')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _masalar.length,
              itemBuilder: (context, i) => _MasaKarti(masa: _masalar[i]),
            ),
    );
  }
}

class _MasaKarti extends StatelessWidget {
  final Masa masa;

  const _MasaKarti({required this.masa});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => context.push('/masalar/${masa.id}'),
        title: Text('Masa ${masa.masaNo}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (masa.prizliMi) const Icon(Icons.bolt, semanticLabel: 'Prizli'),
            if (masa.sessizBolgeMi)
              const Icon(Icons.volume_off, semanticLabel: 'Sessiz bölge'),
          ],
        ),
      ),
    );
  }
}
