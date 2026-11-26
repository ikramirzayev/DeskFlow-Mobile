import '../models/check_in_sonucu.dart';
import 'api_service.dart';

/// QR koddan okunan metni API'ye gönderir. Kuralları (15 dk önce / 15 dk sonra,
/// rezervasyon sahibi mi, durum Beklemede mi) API kontrol eder; uygulama sadece sonucu gösterir.
class CheckInService {
  final ApiService _api;

  CheckInService(this._api);

  Future<CheckInSonucu> checkInYap(String qrKod) async {
    try {
      final cevap = await _api.dio.post(
        '/api/checkin',
        data: {'qrKod': qrKod.trim()},
      );
      return CheckInSonucu.fromJson(cevap.data as Map<String, dynamic>);
    } catch (e) {
      // 400 (erken/geç), 404 (masa ya da rezervasyon yok) mesajları API'den gelir.
      throw ApiService.hataCevir(e);
    }
  }

  /// Elle girilen kod için form kuralı. Hata yoksa null döner.
  static String? kodDogrula(String? deger) {
    final kod = deger?.trim() ?? '';
    if (kod.isEmpty) return 'QR kodunu girin.';
    if (kod.length > 200) return 'Kod en fazla 200 karakter olabilir.';
    return null;
  }
}
