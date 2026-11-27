/// API'deki RezervasyonDto'nun karşılığı (POST ve GET /api/rezervasyonlar/benim).
class Rezervasyon {
  final int id;
  final int masaId;
  final String masaNo;
  final String salonAd;
  final DateTime baslangic;
  final DateTime bitis;
  final String durum;
  final bool iptalEdilebilir;

  const Rezervasyon({
    required this.id,
    required this.masaId,
    required this.masaNo,
    required this.salonAd,
    required this.baslangic,
    required this.bitis,
    required this.durum,
    this.iptalEdilebilir = false,
  });

  factory Rezervasyon.fromJson(Map<String, dynamic> json) {
    return Rezervasyon(
      id: json['id'] as int,
      masaId: json['masaId'] as int,
      masaNo: json['masaNo'] as String? ?? '',
      salonAd: json['salonAd'] as String? ?? '',
      baslangic: DateTime.parse(json['baslangic'] as String).toLocal(),
      bitis: DateTime.parse(json['bitis'] as String).toLocal(),
      durum: json['durum'] as String? ?? '',
      iptalEdilebilir: json['iptalEdilebilir'] as bool? ?? false,
    );
  }
}
