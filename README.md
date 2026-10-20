# DeskFlow Mobile

DeskFlow kütüphane masa rezervasyon sisteminin **Flutter ile geliştirilen iOS uygulaması** (aynı kodla Android'de de çalışır).

Uygulama, ASP.NET Core ile geliştirilen [DeskFlow Web API](https://github.com/ikramirzayev/DeskFlow)'sini kullanır; kendi veritabanı yoktur.

## Ekip

| Ad Soyad | GitHub |
|---|---|
| İkram İRZAYEV | [@ikramirzayev](https://github.com/ikramirzayev) |
| Ali KARA | [@Ali-kara-hub](https://github.com/Ali-kara-hub) |
| Zeynep Şevval YILDIZ | [@zyldzz](https://github.com/zyldzz) |

## Özellikler (planlanan)

- Giriş ve kayıt (JWT)
- Salon listesi ve kat planı üzerinde anlık masa doluluğu
- Masa rezervasyonu ve "Rezervasyonlarım" ekranı
- QR kod okutarak check-in / check-out
- Rezervasyon hatırlatma bildirimleri

## Klasör yapısı

```
lib/
├── main.dart          # Giriş noktası
├── app.dart           # MaterialApp, tema ve başlangıç ekranı
├── core/              # Ayarlar ve sabitler (API adresi vb.)
├── models/            # Veri modelleri (Salon, Masa, Rezervasyon...)
├── services/          # API çağrıları
├── screens/           # Ekranlar
└── widgets/           # Tekrar kullanılan arayüz parçaları
```

## Kurulum

### Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)

- Android için: Android Studio + emülatör
- Çalışan bir [DeskFlow Web API](https://github.com/ikramirzayev/DeskFlow)

### Çalıştırma

```bash
git clone https://github.com/ikramirzayev/DeskFlow-Mobile.git
cd DeskFlow-Mobile
flutter pub get
flutter run
```

### API adresi

Varsayılan adres `http://localhost:5137`'dir. Farklı bir adres için:

| Ortam | Komut |
|---|---|

| Android emülatörü | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5137` |
| Gerçek cihaz | `flutter run --dart-define=API_BASE_URL=http://BILGISAYAR_IP:5137` |

### Test

```bash
flutter analyze
flutter test
```

## Çalışma kuralları

- Herkes kendi GitHub hesabıyla commit ve push yapar.
- Her iş ayrı dalda yapılır (`isim/is-adi`) ve `main`'e Pull Request ile girer.
- İşe başlamadan önce `git pull`.
