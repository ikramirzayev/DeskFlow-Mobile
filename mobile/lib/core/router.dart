import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/checkin_screen.dart';
import '../screens/gecici_ekran.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';
import '../models/masa.dart';
import '../screens/masa_form_screen.dart';
import '../screens/masa_yonetim_screen.dart';
import '../models/salon.dart';
import '../screens/register_screen.dart';
import '../screens/salon_form_screen.dart';
import '../screens/salon_yonetim_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/masa_detay_screen.dart';
import '../screens/masa_list_screen.dart';
import '../screens/rezervasyon_olustur_screen.dart';

/// Uygulamanın bütün adresleri.
abstract final class Adresler {
  static const acilis = '/acilis';
  static const giris = '/giris';
  static const kayit = '/giris/kayit';
  static const anaSayfa = '/';
  static String salon(int salonId) => '/salonlar/$salonId';
  static String masa(int masaId) => '/masalar/$masaId';
  static String rezervasyonOlustur(int masaId) =>
      '/masalar/$masaId/rezervasyon';
  static const salonYonetimi = '/yonetim/salonlar';
  static const salonEkle = '/yonetim/salonlar/yeni';
  static String salonDuzenle(int salonId) => '/yonetim/salonlar/$salonId';
  static const masaYonetimi = '/yonetim/masalar';
<<<<<<< HEAD
  static const masaEkle = '/yonetim/masalar/yeni';
  static String masaDuzenle(int masaId) => '/yonetim/masalar/$masaId';
=======
>>>>>>> origin/main
  static const checkIn = '/checkin';
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
        routes: [
          GoRoute(
            path: 'rezervasyon',
            builder: (context, state) {
              final masaId = int.parse(state.pathParameters['masaId']!);
              return RezervasyonOlusturScreen(masaId: masaId);
            },
          ),
        ],
      ),
      // Giriş yapmış herkes (öğrenci ve yönetici) check-in yapabilir.
      GoRoute(
        path: Adresler.checkIn,
        builder: (context, state) => const CheckInScreen(),
      ),
      // /yonetim ile başlayan adresler oturumYonlendirmesi'nde sadece yöneticiye açık.
      GoRoute(
        path: Adresler.salonYonetimi,
        builder: (context, state) => const SalonYonetimScreen(),
        routes: [
          // 'yeni' önce gelmeli; yoksa ':salonId' onu sayı sanıp yakalardı.
          GoRoute(
            path: 'yeni',
            builder: (context, state) => const SalonFormScreen(),
          ),
          GoRoute(
            path: ':salonId',
            // Düzenlenecek salon listeden 'extra' ile gelir; gelmediyse (ör. uygulama
            // yeniden başlatıldıysa) listeye dön, yanlışlıkla yeni salon eklenmesin.
            redirect: (context, state) =>
                state.extra is Salon ? null : Adresler.salonYonetimi,
            builder: (context, state) =>
                SalonFormScreen(salon: state.extra as Salon?),
          ),
        ],
      ),
      GoRoute(
        path: Adresler.masaYonetimi,
        builder: (context, state) => const MasaYonetimScreen(),
        routes: [
          // 'yeni' önce gelmeli; yoksa ':masaId' onu sayı sanıp yakalardı.
          GoRoute(
            path: 'yeni',
            builder: (context, state) => const MasaFormScreen(),
          ),
          GoRoute(
            path: ':masaId',
            // Düzenlenecek masa listeden 'extra' ile gelir; gelmediyse listeye dön,
            // yanlışlıkla yeni masa eklenmesin.
            redirect: (context, state) =>
                state.extra is Masa ? null : Adresler.masaYonetimi,
            builder: (context, state) =>
                MasaFormScreen(masa: state.extra as Masa?),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const GeciciEkran(
      baslik: 'Sayfa bulunamadı',
      mesaj: 'Aradığınız sayfa yok.',
    ),
  );
}
