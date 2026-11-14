import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/gecici_ekran.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/masa_detay_screen.dart';
import '../screens/masa_list_screen.dart';

/// Uygulamanın bütün adresleri.
abstract final class Adresler {
  static const acilis = '/acilis';
  static const giris = '/giris';
  static const kayit = '/giris/kayit';
  static const anaSayfa = '/';
  static String salon(int salonId) => '/salonlar/$salonId';
  static String masa(int masaId) => '/masalar/$masaId';
  static const salonYonetimi = '/yonetim/salonlar';
  static const masaYonetimi = '/yonetim/masalar';
}

/// Oturum durumuna göre gidilmek istenen adresin yerine nereye gidileceğini söyler.
/// null dönerse istenen adrese gidilir. Widget'tan bağımsız olduğu için test edilebilir.
String? oturumYonlendirmesi({
  required OturumDurumu durum,
  required bool yoneticiMi,
  required String konum,
}) {
  if (durum == OturumDurumu.baslatiliyor) {
    return konum == Adresler.acilis ? null : Adresler.acilis;
  }

  final girisSayfasinda = konum == Adresler.giris || konum == Adresler.kayit;

  if (durum == OturumDurumu.girisYapilmadi) {
    return girisSayfasinda ? null : Adresler.giris;
  }

  // Giriş yapılmış.
  if (girisSayfasinda || konum == Adresler.acilis) {
    return Adresler.anaSayfa;
  }
  if (konum.startsWith('/yonetim') && !yoneticiMi) {
    return Adresler.anaSayfa;
  }
  return null;
}

GoRouter routerOlustur(AuthProvider auth) {
  return GoRouter(
    initialLocation: Adresler.acilis,
    // Oturum değişince (giriş, çıkış, token süresi) yönlendirme yeniden çalışır.
    refreshListenable: auth,
    redirect: (context, state) => oturumYonlendirmesi(
      durum: auth.durum,
      yoneticiMi: auth.yoneticiMi,
      konum: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: Adresler.acilis,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Adresler.giris,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'kayit',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Adresler.anaSayfa,
        builder: (context, state) => const MainShell(),
      ),
      // Zeynep: aşağıdaki iki GeciciEkran'ı MasaListScreen ve MasaDetayScreen ile değiştir.
      GoRoute(
        path: '/salonlar/:salonId',
        builder: (context, state) {
          final salonId = int.parse(state.pathParameters['salonId']!);
          return MasaListScreen(salonId: salonId);
        },
      ),
      GoRoute(
        path: '/masalar/:masaId',
        builder: (context, state) {
          final masaId = int.parse(state.pathParameters['masaId']!);
          return MasaDetayScreen(masaId: masaId);
        },
      ),
      // Yönetim ekranları 5. haftada yapılacak; adresler şimdiden korunuyor.
      GoRoute(
        path: Adresler.salonYonetimi,
        builder: (context, state) => const GeciciEkran(
          baslik: 'Salon Yönetimi',
          mesaj: 'Salon ekleme, düzenleme ve silme 5. haftada eklenecek.',
        ),
      ),
      GoRoute(
        path: Adresler.masaYonetimi,
        builder: (context, state) => const GeciciEkran(
          baslik: 'Masa Yönetimi',
          mesaj: 'Masa ekleme, düzenleme ve silme 5. haftada eklenecek.',
        ),
      ),
    ],
    errorBuilder: (context, state) => const GeciciEkran(
      baslik: 'Sayfa bulunamadı',
      mesaj: 'Aradığınız sayfa yok.',
    ),
  );
}
