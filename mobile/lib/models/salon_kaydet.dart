import 'package:flutter/material.dart';

/// Salon ekleme / güncelleme isteği. API'deki SalonKaydetDto'nun karşılığı.
class SalonKaydet {
  final String ad;
  final int kat;
  final int kapasite;
  final TimeOfDay acilisSaati;
  final TimeOfDay kapanisSaati;
  final bool aktifMi;

  const SalonKaydet({
    required this.ad,
    required this.kat,
    required this.kapasite,
    required this.acilisSaati,
    required this.kapanisSaati,
    required this.aktifMi,
  });

  /// API TimeOnly alanlarını "08:00:00" biçiminde bekler.
  Map<String, dynamic> toJson() => {
        'ad': ad.trim(),
        'kat': kat,
        'kapasite': kapasite,
        'acilisSaati': saatMetni(acilisSaati),
        'kapanisSaati': saatMetni(kapanisSaati),
        'aktifMi': aktifMi,
      };

  static String saatMetni(TimeOfDay saat) {
    final ss = saat.hour.toString().padLeft(2, '0');
    final dd = saat.minute.toString().padLeft(2, '0');
    return '$ss:$dd:00';
  }

  /// "08:00" ya da "08:00:00" metnini TimeOfDay'e çevirir. Okunamazsa null döner.
  static TimeOfDay? saatOku(String metin) {
    final parcalar = metin.split(':');
    if (parcalar.length < 2) return null;
    final saat = int.tryParse(parcalar[0]);
    final dakika = int.tryParse(parcalar[1]);
    if (saat == null || dakika == null) return null;
    if (saat < 0 || saat > 23 || dakika < 0 || dakika > 59) return null;
    return TimeOfDay(hour: saat, minute: dakika);
  }
}

/// Formdaki kurallar API'deki SalonKaydetDto ile aynı.
/// Hata yoksa null, varsa ekranda gösterilecek mesajı döner.
abstract final class SalonDogrulama {
  static String? ad(String? deger) {
    final metin = deger?.trim() ?? '';
    if (metin.isEmpty) return 'Salon adı zorunludur.';
    if (metin.length > 100) return 'Salon adı en fazla 100 karakter olabilir.';
    return null;
  }

  static String? kat(String? deger) {
    final sayi = int.tryParse(deger?.trim() ?? '');
    if (sayi == null) return 'Kat bir sayı olmalıdır.';
    if (sayi < -2 || sayi > 20) return 'Kat -2 ile 20 arasında olmalıdır.';
    return null;
  }

  static String? kapasite(String? deger) {
    final sayi = int.tryParse(deger?.trim() ?? '');
    if (sayi == null) return 'Kapasite bir sayı olmalıdır.';
    if (sayi < 1 || sayi > 1000) return 'Kapasite 1 ile 1000 arasında olmalıdır.';
    return null;
  }

  static String? saatler(TimeOfDay acilis, TimeOfDay kapanis) {
    final acilisDakika = acilis.hour * 60 + acilis.minute;
    final kapanisDakika = kapanis.hour * 60 + kapanis.minute;
    if (kapanisDakika <= acilisDakika) {
      return 'Kapanış saati açılış saatinden sonra olmalıdır.';
    }
    return null;
  }
}
