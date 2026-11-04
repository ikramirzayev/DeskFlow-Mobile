import 'package:dio/dio.dart';

import '../core/config.dart';

/// API'den dönen hatayı kullanıcıya gösterilecek Türkçe bir mesajla taşır.
class ApiHatasi implements Exception {
  final String mesaj;
  final int? durumKodu;

  const ApiHatasi(this.mesaj, {this.durumKodu});

  @override
  String toString() => mesaj;
}

/// Bütün HTTP istekleri bu sınıftan geçer.
/// Token varsa her isteğe "Authorization: Bearer ..." başlığını ekler.
class ApiService {
  final Dio dio;

  String? _token;

  /// Token'lı bir istek 401 dönerse çağrılır (oturum düşürülür).
  void Function()? oturumDustu;

  ApiService({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                contentType: 'application/json',
              ),
            ) {
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final token = _token;
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              handler.next(options);
            },
            onError: (e, handler) {
              final tokenliIstek =
                  e.requestOptions.headers.containsKey('Authorization');
              if (e.response?.statusCode == 401 && tokenliIstek) {
                oturumDustu?.call();
              }
              handler.next(e);
            },
          ),
        );
  }

  void tokenAyarla(String? token) => _token = token;

  /// DioException'ı kullanıcıya gösterilecek bir mesaja çevirir.
  static ApiHatasi hataCevir(Object hata) {
    if (hata is ApiHatasi) return hata;
    if (hata is! DioException) {
      return const ApiHatasi('Beklenmeyen bir hata oluştu.');
    }

    switch (hata.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const ApiHatasi('Sunucuya ulaşılamıyor. API çalışıyor mu?');
      default:
        break;
    }

    final kod = hata.response?.statusCode;
    final veri = hata.response?.data;
    final sunucuMesaji = (veri is Map && veri['mesaj'] is String)
        ? veri['mesaj'] as String
        : null;

    switch (kod) {
      case 400:
        return ApiHatasi(_dogrulamaMesajlari(veri) ?? 'Girilen bilgiler hatalı.',
            durumKodu: kod);
      case 401:
        return ApiHatasi(
            sunucuMesaji ?? 'Oturum süresi doldu, lütfen tekrar giriş yapın.',
            durumKodu: kod);
      case 403:
        return ApiHatasi('Bu işlem için yetkiniz yok.', durumKodu: kod);
      case 404:
        return ApiHatasi(sunucuMesaji ?? 'Kayıt bulunamadı.', durumKodu: kod);
      case 409:
        return ApiHatasi(sunucuMesaji ?? 'İşlem yapılamadı.', durumKodu: kod);
      default:
        return ApiHatasi(
            'Beklenmeyen bir hata oluştu${kod != null ? ' ($kod)' : ''}.',
            durumKodu: kod);
    }
  }

  /// ASP.NET Core doğrulama cevabındaki ("errors": {alan: [mesaj]}) mesajları birleştirir.
  static String? _dogrulamaMesajlari(Object? veri) {
    if (veri is! Map || veri['errors'] is! Map) return null;
    final hatalar = veri['errors'] as Map;
    final mesajlar = <String>[];
    for (final liste in hatalar.values) {
      if (liste is List) {
        mesajlar.addAll(liste.map((m) => m.toString()));
      }
    }
    return mesajlar.isEmpty ? null : mesajlar.join('\n');
  }
}
