/// POST /api/checkin başarılı cevabı. API, rezervasyonun güncel halini
/// RezervasyonDto biçiminde döner; ekranda gereken alanları okuyoruz.
class CheckInSonucu {
  final int rezervasyonId;
  final String salonAd;
  final String masaNo;
  final int kat;
  final DateTime baslangic;
  final DateTime bitis;
  final String durum;

  const CheckInSonucu({
    required this.rezervasyonId,
    required this.salonAd,
    required this.masaNo,
    required this.kat,
    required this.baslangic,
    required this.bitis,
    required this.durum,
  });

  factory CheckInSonucu.fromJson(Map<String, dynamic> json) {
    return CheckInSonucu(
      rezervasyonId: json['id'] as int,
      salonAd: json['salonAd'] as String? ?? '',
      masaNo: json['masaNo'] as String? ?? '',
      kat: json['kat'] as int? ?? 0,
      // API saatleri sunucunun yerel saatiyle, saat dilimi eki olmadan gönderir.
      baslangic: DateTime.parse(json['baslangic'] as String),
      bitis: DateTime.parse(json['bitis'] as String),
      durum: json['durum'] as String? ?? '',
    );
  }

  /// "14:00 – 16:00"
  String get saatAraligi => '${_ikiHane(baslangic.hour)}:${_ikiHane(baslangic.minute)} – '
      '${_ikiHane(bitis.hour)}:${_ikiHane(bitis.minute)}';

  static String _ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
}
