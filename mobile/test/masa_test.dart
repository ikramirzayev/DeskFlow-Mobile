import 'package:flutter_test/flutter_test.dart';

import 'package:deskflow_mobile/models/masa.dart';

void main() {
  group('Masa.fromJson', () {
    test('API cevabını doğru okur', () {
      final masa = Masa.fromJson({
        'id': 1,
        'masaNo': 'A1',
        'salonId': 1,
        'salonAd': 'Sessiz Salon',
        'x': 1.0,
        'y': 3,
        'prizliMi': true,
        'sessizBolgeMi': true,
        'aktifMi': true,
      });

      expect(masa.id, 1);
      expect(masa.masaNo, 'A1');
      expect(masa.salonId, 1);
      expect(masa.salonAd, 'Sessiz Salon');
      expect(masa.x, 1.0);
      expect(masa.y, 3.0);
      expect(masa.prizliMi, isTrue);
      expect(masa.sessizBolgeMi, isTrue);
      expect(masa.aktifMi, isTrue);
    });

    test('eksik alanlarda varsayılan değer verir', () {
      final masa = Masa.fromJson({'id': 2});

      expect(masa.masaNo, '');
      expect(masa.prizliMi, isFalse);
      expect(masa.aktifMi, isFalse);
    });
  });
}
