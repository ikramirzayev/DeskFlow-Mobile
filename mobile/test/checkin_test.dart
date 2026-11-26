import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:deskflow_mobile/screens/checkin_screen.dart';
import 'package:deskflow_mobile/services/api_service.dart';
import 'package:deskflow_mobile/services/checkin_service.dart';

import 'yardimcilar.dart';

const basariliCevap = {
  'id': 12,
  'masaId': 1,
  'masaNo': 'A1',
  'salonId': 1,
  'salonAd': 'Sessiz Salon',
  'kat': 1,
  'baslangic': '2026-12-02T14:00:00',
  'bitis': '2026-12-02T16:00:00',
  'durum': 'Aktif',
  'iptalEdilebilir': false,
};

Future<void> ekraniAc(WidgetTester tester, KaydedenAdapter adapter) {
  return tester.pumpWidget(
    Provider<ApiService>.value(
      value: apiIle(adapter),
      child: const MaterialApp(home: CheckInScreen(kameraAcik: false)),
    ),
  );
}

void main() {
  group('CheckInService', () {
    test('POST /api/checkin kodu kırpıp gönderir, cevabı okur', () async {
      final adapter = KaydedenAdapter(200, basariliCevap);
      final sonuc = await CheckInService(apiIle(adapter)).checkInYap('  DESKFLOW-S1-A1 ');

      expect(adapter.sonIstek!.method, 'POST');
      expect(adapter.sonIstek!.path, '/api/checkin');
      expect(adapter.sonIstek!.data, {'qrKod': 'DESKFLOW-S1-A1'});
      expect(sonuc.masaNo, 'A1');
      expect(sonuc.durum, 'Aktif');
      expect(sonuc.saatAraligi, '14:00 – 16:00');
    });

    test('400 gelirse API mesajıyla hata fırlatır', () async {
      final adapter = KaydedenAdapter(400, {'mesaj': 'Check-in 13:45 itibarıyla yapılabilir.'});

      await expectLater(
        CheckInService(apiIle(adapter)).checkInYap('DESKFLOW-S1-A1'),
        throwsA(
          isA<ApiHatasi>()
              .having((h) => h.durumKodu, 'durumKodu', 400)
              .having((h) => h.mesaj, 'mesaj', 'Check-in 13:45 itibarıyla yapılabilir.'),
        ),
      );
    });

    test('kodDogrula boş kodu reddeder', () {
      expect(CheckInService.kodDogrula('   '), isNotNull);
      expect(CheckInService.kodDogrula('DESKFLOW-S1-A1'), isNull);
    });
  });

  testWidgets('Boş kodla Check-in yap uyarı gösterir, istek atmaz', (tester) async {
    final adapter = KaydedenAdapter(200, basariliCevap);
    await ekraniAc(tester, adapter);

    await tester.tap(find.text('Check-in yap'));
    await tester.pump();

    expect(find.text('QR kodunu girin.'), findsOneWidget);
    expect(adapter.sonIstek, isNull);
  });

  testWidgets('Elle girilen kod başarılıysa onay kartı görünür', (tester) async {
    final adapter = KaydedenAdapter(200, basariliCevap);
    await ekraniAc(tester, adapter);

    await tester.enterText(find.byType(TextFormField), 'DESKFLOW-S1-A1');
    await tester.tap(find.text('Check-in yap'));
    await tester.pumpAndSettle();

    expect(find.text('Check-in yapıldı'), findsOneWidget);
    expect(find.text('Masa A1 · 14:00 – 16:00'), findsOneWidget);
  });

  testWidgets('API hata dönerse mesaj ve Tekrar dene görünür', (tester) async {
    final adapter = KaydedenAdapter(404, {'mesaj': 'Bu masada size ait bir rezervasyon yok.'});
    await ekraniAc(tester, adapter);

    await tester.enterText(find.byType(TextFormField), 'DESKFLOW-S1-A1');
    await tester.tap(find.text('Check-in yap'));
    await tester.pumpAndSettle();

    expect(find.text('Bu masada size ait bir rezervasyon yok.'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });
}
