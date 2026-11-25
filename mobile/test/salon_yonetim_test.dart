import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:deskflow_mobile/models/salon_kaydet.dart';
import 'package:deskflow_mobile/screens/salon_form_screen.dart';
import 'package:deskflow_mobile/services/api_service.dart';
import 'package:deskflow_mobile/services/salon_service.dart';

/// Giden isteği kaydeden ve verilen cevabı dönen sahte bağlantı.
class KaydedenAdapter implements HttpClientAdapter {
  KaydedenAdapter(this.durumKodu, this.cevap);

  final int durumKodu;
  final Object cevap;
  RequestOptions? sonIstek;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sonIstek = options;
    return ResponseBody.fromString(
      jsonEncode(cevap),
      durumKodu,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const ornekSalonJson = {
  'id': 7,
  'ad': 'Yeni Salon',
  'kat': 2,
  'kapasite': 40,
  'acilisSaati': '09:00:00',
  'kapanisSaati': '21:00:00',
  'aktifMi': true,
  'masaSayisi': 0,
};

const ornekIstek = SalonKaydet(
  ad: '  Yeni Salon  ',
  kat: 2,
  kapasite: 40,
  acilisSaati: TimeOfDay(hour: 9, minute: 0),
  kapanisSaati: TimeOfDay(hour: 21, minute: 0),
  aktifMi: true,
);

ApiService apiIle(HttpClientAdapter adapter) =>
    ApiService(dio: Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = adapter);

void main() {
  group('SalonKaydet', () {
    test('toJson saatleri API biçiminde ve adı kırpılmış gönderir', () {
      expect(ornekIstek.toJson(), {
        'ad': 'Yeni Salon',
        'kat': 2,
        'kapasite': 40,
        'acilisSaati': '09:00:00',
        'kapanisSaati': '21:00:00',
        'aktifMi': true,
      });
    });

    test('saatOku geçerli ve geçersiz metinleri ayırır', () {
      expect(SalonKaydet.saatOku('08:30'), const TimeOfDay(hour: 8, minute: 30));
      expect(SalonKaydet.saatOku('23:00:00'), const TimeOfDay(hour: 23, minute: 0));
      expect(SalonKaydet.saatOku(''), isNull);
      expect(SalonKaydet.saatOku('25:00'), isNull);
    });
  });

  group('SalonDogrulama', () {
    test('kurallar API ile aynı', () {
      expect(SalonDogrulama.ad('   '), isNotNull);
      expect(SalonDogrulama.ad('Sessiz Salon'), isNull);
      expect(SalonDogrulama.kat('-3'), isNotNull);
      expect(SalonDogrulama.kat('-2'), isNull);
      expect(SalonDogrulama.kapasite('0'), isNotNull);
      expect(SalonDogrulama.kapasite('abc'), isNotNull);
      expect(SalonDogrulama.kapasite('60'), isNull);
      expect(
        SalonDogrulama.saatler(
          const TimeOfDay(hour: 20, minute: 0),
          const TimeOfDay(hour: 8, minute: 0),
        ),
        isNotNull,
      );
    });
  });

  group('SalonService', () {
    test('ekle POST /api/salonlar isteği atar ve cevabı okur', () async {
      final adapter = KaydedenAdapter(201, ornekSalonJson);
      final salon = await SalonService(apiIle(adapter)).ekle(ornekIstek);

      expect(adapter.sonIstek!.method, 'POST');
      expect(adapter.sonIstek!.path, '/api/salonlar');
      expect(salon.id, 7);
      expect(salon.acilisSaati, '09:00');
    });

    test('sil 409 gelirse sunucunun mesajıyla hata fırlatır', () async {
      final adapter = KaydedenAdapter(409, {'mesaj': 'Rezervasyonu olan salon silinemez.'});
      final servis = SalonService(apiIle(adapter));

      await expectLater(
        servis.sil(3),
        throwsA(
          isA<ApiHatasi>()
              .having((h) => h.durumKodu, 'durumKodu', 409)
              .having((h) => h.mesaj, 'mesaj', 'Rezervasyonu olan salon silinemez.'),
        ),
      );
      expect(adapter.sonIstek!.method, 'DELETE');
      expect(adapter.sonIstek!.path, '/api/salonlar/3');
    });
  });

  testWidgets('Boş formda Kaydet hata mesajı gösterir, istek atmaz', (tester) async {
    final adapter = KaydedenAdapter(201, ornekSalonJson);
    await tester.pumpWidget(
      Provider<ApiService>.value(
        value: apiIle(adapter),
        child: const MaterialApp(home: SalonFormScreen()),
      ),
    );

    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    expect(find.text('Salon adı zorunludur.'), findsOneWidget);
    expect(find.text('Kapasite bir sayı olmalıdır.'), findsOneWidget);
    expect(adapter.sonIstek, isNull);
  });
}
