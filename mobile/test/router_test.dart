import 'package:flutter_test/flutter_test.dart';

import 'package:deskflow_mobile/core/router.dart';
import 'package:deskflow_mobile/providers/auth_provider.dart';

void main() {
  String? git(OturumDurumu durum, String konum, {bool yonetici = false}) =>
      oturumYonlendirmesi(durum: durum, yoneticiMi: yonetici, konum: konum);

  test('açılış sırasında her adres açılış ekranına gider', () {
    expect(git(OturumDurumu.baslatiliyor, '/'), Adresler.acilis);
    expect(git(OturumDurumu.baslatiliyor, Adresler.acilis), isNull);
  });

  test('giriş yapmamış kullanıcı korumalı adreslerden girişe yönlenir', () {
    expect(git(OturumDurumu.girisYapilmadi, '/'), Adresler.giris);
    expect(git(OturumDurumu.girisYapilmadi, '/salonlar/1'), Adresler.giris);
    expect(git(OturumDurumu.girisYapilmadi, Adresler.giris), isNull);
    expect(git(OturumDurumu.girisYapilmadi, Adresler.kayit), isNull);
  });

  test('giriş yapmış kullanıcı giriş ekranından ana sayfaya yönlenir', () {
    expect(git(OturumDurumu.girisYapildi, Adresler.giris), Adresler.anaSayfa);
    expect(git(OturumDurumu.girisYapildi, Adresler.kayit), Adresler.anaSayfa);
    expect(git(OturumDurumu.girisYapildi, '/salonlar/1'), isNull);
  });

  test('yönetim ekranları sadece yöneticiye açık', () {
    expect(git(OturumDurumu.girisYapildi, Adresler.salonYonetimi),
        Adresler.anaSayfa);
    expect(
        git(OturumDurumu.girisYapildi, Adresler.salonYonetimi, yonetici: true),
        isNull);
  });
}
