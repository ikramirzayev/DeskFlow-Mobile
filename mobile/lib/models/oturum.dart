/// Giriş ya da kayıttan sonra API'nin döndürdüğü oturum bilgisi (TokenDto).
class Oturum {
  final String token;
  final DateTime bitisZamani;
  final String email;
  final String adSoyad;
  final List<String> roller;

  const Oturum({
    required this.token,
    required this.bitisZamani,
    required this.email,
    required this.adSoyad,
    required this.roller,
  });

  bool get yoneticiMi => roller.contains('Yonetici');

  bool get suresiDolduMu => DateTime.now().toUtc().isAfter(bitisZamani);

  factory Oturum.fromJson(Map<String, dynamic> json) {
    return Oturum(
      token: json['token'] as String,
      bitisZamani: DateTime.parse(json['bitisZamani'] as String).toUtc(),
      email: json['email'] as String? ?? '',
      adSoyad: json['adSoyad'] as String? ?? '',
      roller: (json['roller'] as List<dynamic>? ?? [])
          .map((r) => r.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'bitisZamani': bitisZamani.toIso8601String(),
        'email': email,
        'adSoyad': adSoyad,
        'roller': roller,
      };
}
