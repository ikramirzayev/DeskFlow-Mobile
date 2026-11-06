import 'package:flutter_test/flutter_test.dart';

import 'package:deskflow_mobile/models/salon.dart';

void main() {
  group('Salon.fromJson', () {
    test('API cevabını doğru okur', () {
      final salon = Salon.fromJson({
        'id': 1,
        'ad': 'Sessiz Salon',
        'kat': 1,
        'kapasite': 60,
        'acilisSaati': '08:00:00',
        'kapanisSaati': '23:00:00',
        'aktifMi': true,
        'masaSayisi': 6,
      });

      expect(salon.id, 1);
      expect(salon.ad, 'Sessiz Salon');
      expect(salon.kat, 1);
      expect(salon.kapasite, 60);
      expect(salon.acilisSaati, '08:00');
      expect(salon.kapanisSaati, '23:00');
      expect(salon.aktifMi, isTrue);
      expect(salon.masaSayisi, 6);
    });

    test('eksik alanlarda varsayılan değer verir', () {
      final salon = Salon.fromJson({'id': 2});

      expect(salon.ad, '');
      expect(salon.aktifMi, isFalse);
      expect(salon.masaSayisi, 0);
    });
  });
}
