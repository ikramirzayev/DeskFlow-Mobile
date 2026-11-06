/// API'deki SalonDto'nun karşılığı (GET /api/salonlar).
class Salon {
  final int id;
  final String ad;
  final int kat;
  final int kapasite;
  final String acilisSaati; // "08:00"
  final String kapanisSaati; // "23:00"
  final bool aktifMi;
  final int masaSayisi;

  const Salon({
    required this.id,
    required this.ad,
    required this.kat,
    required this.kapasite,
    required this.acilisSaati,
    required this.kapanisSaati,
    required this.aktifMi,
    required this.masaSayisi,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] as int,
      ad: json['ad'] as String? ?? '',
      kat: json['kat'] as int? ?? 0,
      kapasite: json['kapasite'] as int? ?? 0,
      acilisSaati: _saatKisalt(json['acilisSaati']),
      kapanisSaati: _saatKisalt(json['kapanisSaati']),
      aktifMi: json['aktifMi'] as bool? ?? false,
      masaSayisi: json['masaSayisi'] as int? ?? 0,
    );
  }

  /// API "08:00:00" gönderir, ekranda "08:00" gösteririz.
  static String _saatKisalt(Object? deger) {
    final s = deger?.toString() ?? '';
    return s.length >= 5 ? s.substring(0, 5) : s;
  }
}
