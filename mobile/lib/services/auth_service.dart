import '../models/oturum.dart';
import 'api_service.dart';

/// /api/auth uç noktalarını çağırır.
class AuthService {
  final ApiService _api;

  AuthService(this._api);

  Future<Oturum> giris(String email, String sifre) async {
    try {
      final cevap = await _api.dio.post<Map<String, dynamic>>(
        '/api/auth/giris',
        data: {'email': email, 'sifre': sifre},
      );
      return Oturum.fromJson(cevap.data!);
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }

  Future<Oturum> kayit({
    required String ad,
    required String soyad,
    required String ogrenciNo,
    required String email,
    required String sifre,
  }) async {
    try {
      final cevap = await _api.dio.post<Map<String, dynamic>>(
        '/api/auth/kayit',
        data: {
          'ad': ad,
          'soyad': soyad,
          'ogrenciNo': ogrenciNo,
          'email': email,
          'sifre': sifre,
        },
      );
      return Oturum.fromJson(cevap.data!);
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }

  /// Token sahibinin bilgileri (GET /api/auth/ben). Token gerektirir.
  Future<Map<String, dynamic>> ben() async {
    try {
      final cevap = await _api.dio.get<Map<String, dynamic>>('/api/auth/ben');
      return cevap.data!;
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }
}
