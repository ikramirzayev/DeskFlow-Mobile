import 'package:flutter/foundation.dart';

import '../models/oturum.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/token_store.dart';

enum OturumDurumu { baslatiliyor, girisYapilmadi, girisYapildi }

/// Uygulamanın oturum durumunu tutar; ekranlar bunu dinleyerek değişir.
class AuthProvider extends ChangeNotifier {
  final ApiService _api;
  final AuthService _authService;
  final TokenStore _tokenStore;

  OturumDurumu _durum = OturumDurumu.baslatiliyor;
  Oturum? _oturum;

  AuthProvider(this._api, this._tokenStore) : _authService = AuthService(_api) {
    _api.oturumDustu = () => cikis();
  }

  OturumDurumu get durum => _durum;
  Oturum? get oturum => _oturum;
  bool get girisYapildi => _durum == OturumDurumu.girisYapildi;
  bool get yoneticiMi => _oturum?.yoneticiMi ?? false;
  AuthService get authService => _authService;

  /// Uygulama açılırken çağrılır: saklı ve süresi dolmamış oturum varsa devam eder.
  /// Açılış ekranı en az [minSure] kadar görünür.
  Future<void> baslat({Duration minSure = const Duration(seconds: 2)}) async {
    final sonuclar = await Future.wait<Object?>([
      _guvenliOku(),
      Future<Object?>.delayed(minSure),
    ]);
    final kayitli = sonuclar.first as Oturum?;

    if (kayitli != null && !kayitli.suresiDolduMu) {
      _oturumuAc(kayitli);
    } else {
      _durum = OturumDurumu.girisYapilmadi;
      notifyListeners();
    }
  }

  /// Depo okunamazsa (ör. testlerde) oturum yok sayılır.
  Future<Oturum?> _guvenliOku() async {
    try {
      return await _tokenStore.oku();
    } catch (_) {
      return null;
    }
  }

  Future<void> giris(String email, String sifre) async {
    final oturum = await _authService.giris(email, sifre);
    await _tokenStore.kaydet(oturum);
    _oturumuAc(oturum);
  }

  Future<void> kayit({
    required String ad,
    required String soyad,
    required String ogrenciNo,
    required String email,
    required String sifre,
  }) async {
    final oturum = await _authService.kayit(
      ad: ad,
      soyad: soyad,
      ogrenciNo: ogrenciNo,
      email: email,
      sifre: sifre,
    );
    await _tokenStore.kaydet(oturum);
    _oturumuAc(oturum);
  }

  Future<void> cikis() async {
    _oturum = null;
    _api.tokenAyarla(null);
    _durum = OturumDurumu.girisYapilmadi;
    notifyListeners();
    try {
      await _tokenStore.sil();
    } catch (_) {
      // Silinemese de oturum bellekte kapatıldı; devam ediyoruz.
    }
  }

  void _oturumuAc(Oturum oturum) {
    _oturum = oturum;
    _api.tokenAyarla(oturum.token);
    _durum = OturumDurumu.girisYapildi;
    notifyListeners();
  }
}
