/// Masa ekleme / güncelleme isteği. API'deki MasaKaydetDto'nun karşılığı.
/// QR kodu API kendisi üretir (DESKFLOW-S{salonId}-{masaNo}), burada gönderilmez.
class MasaKaydet {
  final String masaNo;
  final int salonId;
  final double x;
  final double y;
  final bool prizliMi;
  final bool sessizBolgeMi;
  final bool aktifMi;

  const MasaKaydet({
    required this.masaNo,
    required this.salonId,
    required this.x,
    required this.y,
    required this.prizliMi,
    required this.sessizBolgeMi,
    required this.aktifMi,
  });

  Map<String, dynamic> toJson() => {
        'masaNo': masaNo.trim(),
        'salonId': salonId,
        'x': x,
        'y': y,
        'prizliMi': prizliMi,
        'sessizBolgeMi': sessizBolgeMi,
        'aktifMi': aktifMi,
      };
}

/// Formdaki kurallar API'deki MasaKaydetDto ile aynı.
/// Hata yoksa null, varsa ekranda gösterilecek mesajı döner.
abstract final class MasaDogrulama {
  static String? masaNo(String? deger) {
    final metin = deger?.trim() ?? '';
    if (metin.isEmpty) return 'Masa numarası zorunludur.';
    if (metin.length > 20) return 'Masa numarası en fazla 20 karakter olabilir.';
    return null;
  }

  /// Boş bırakılırsa 0 sayılır; yazıldıysa sayı olmalıdır. Virgül de kabul edilir.
  static String? koordinat(String? deger) {
    final metin = deger?.trim() ?? '';
    if (metin.isEmpty) return null;
    return koordinatOku(metin) == null ? 'Sayı girin (örn. 2.5).' : null;
  }

  static double? koordinatOku(String metin) =>
      double.tryParse(metin.trim().replaceAll(',', '.'));
}
