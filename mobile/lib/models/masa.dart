/// API'deki MasaDto'nun karşılığı (GET /api/masalar).
class Masa {
  final int id;
  final String masaNo;
  final int salonId;
  final String salonAd;
  final double x;
  final double y;
  final bool prizliMi;
  final bool sessizBolgeMi;
  final bool aktifMi;

  const Masa({
    required this.id,
    required this.masaNo,
    required this.salonId,
    required this.salonAd,
    required this.x,
    required this.y,
    required this.prizliMi,
    required this.sessizBolgeMi,
    required this.aktifMi,
  });

  factory Masa.fromJson(Map<String, dynamic> json) {
    return Masa(
      id: json['id'] as int,
      masaNo: json['masaNo'] as String? ?? '',
      salonId: json['salonId'] as int? ?? 0,
      salonAd: json['salonAd'] as String? ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      prizliMi: json['prizliMi'] as bool? ?? false,
      sessizBolgeMi: json['sessizBolgeMi'] as bool? ?? false,
      aktifMi: json['aktifMi'] as bool? ?? false,
    );
  }
}
