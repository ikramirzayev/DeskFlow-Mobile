import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deskflow_mobile/models/oturum.dart';
import 'package:deskflow_mobile/services/api_service.dart';

void main() {
  group('Oturum', () {
    test('API cevabından oluşturulur ve rolü tanır', () {
      final oturum = Oturum.fromJson({
        'token': 'abc',
        'bitisZamani': '2099-01-01T00:00:00Z',
        'email': 'yonetici@deskflow.local',
        'adSoyad': 'Sistem Yöneticisi',
        'roller': ['Yonetici'],
      });

      expect(oturum.token, 'abc');
      expect(oturum.yoneticiMi, isTrue);
      expect(oturum.suresiDolduMu, isFalse);
    });

    test('süresi geçmiş token tanınır', () {
      final oturum = Oturum.fromJson({
        'token': 'abc',
        'bitisZamani': '2000-01-01T00:00:00Z',
        'roller': ['Ogrenci'],
      });

      expect(oturum.yoneticiMi, isFalse);
      expect(oturum.suresiDolduMu, isTrue);
    });
  });

  group('ApiService.hataCevir', () {
    DioException hata(int kod, Object? veri) {
      final istek = RequestOptions(path: '/');
      return DioException(
        requestOptions: istek,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: istek, statusCode: kod, data: veri),
      );
    }

    test('400 doğrulama mesajlarını birleştirir', () {
      final sonuc = ApiService.hataCevir(hata(400, {
        'errors': {
          'Ad': ['Ad zorunludur.'],
          'Email': ['Geçerli bir e-posta adresi girin.'],
        },
      }));

      expect(sonuc.mesaj, contains('Ad zorunludur.'));
      expect(sonuc.mesaj, contains('Geçerli bir e-posta adresi girin.'));
    });

    test('401 sunucunun mesajını kullanır', () {
      final sonuc =
          ApiService.hataCevir(hata(401, {'mesaj': 'E-posta veya şifre hatalı.'}));
      expect(sonuc.mesaj, 'E-posta veya şifre hatalı.');
    });

    test('bağlantı hatası anlaşılır mesaj verir', () {
      final sonuc = ApiService.hataCevir(DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      ));
      expect(sonuc.mesaj, contains('Sunucuya ulaşılamıyor'));
    });
  });
}
