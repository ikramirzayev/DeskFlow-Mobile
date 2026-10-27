# DeskFlow

**Akıllı Çalışma Alanı ve Kütüphane Masa Rezervasyon Uygulaması**

DeskFlow; kütüphane ve çalışma salonlarındaki masaların doluluğunun kat planı üzerinde izlendiği, masaların önceden rezerve edildiği ve masadaki QR kod okutularak check-in yapıldığı bir mobil uygulamadır.

> BLM4587 IOS İle Mobil Uygulama Geliştirme I (Flutter) – 2026–2027 Güz dönem projesi

## Ekip

| Ad Soyad | GitHub |
|---|---|
| İkram İRZAYEV | [@ikramirzayev](https://github.com/ikramirzayev) |
| Ali KARA | [@Ali-kara-hub](https://github.com/Ali-kara-hub) |
| Zeynep Şevval YILDIZ | [@zyldzz](https://github.com/zyldzz) |

## Depo yapısı

```
DeskFlow-Mobile/
├── api/       # ASP.NET Core Web API (C#, EF Core, PostgreSQL, JWT)
└── mobile/    # Flutter (Dart) Android uygulaması
```

Mobil uygulama veritabanına doğrudan bağlanmaz; tüm verilere `api/` içindeki Web API üzerinden erişir.

## Teknolojiler

| Parça | Teknoloji |
|---|---|
| Web API | ASP.NET Core Web API, Entity Framework Core, PostgreSQL (Npgsql), Identity + JWT, Swagger |
| Mobil | Flutter (Dart), provider, go_router, dio, flutter_secure_storage, mobile_scanner |
| Platform | Android |

---

## 1. Web API (`api/`)

### Gereksinimler

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [PostgreSQL](https://www.postgresql.org/download/) (16 veya üzeri)
- EF Core aracı: `dotnet tool install --global dotnet-ef`

### Veritabanı bağlantısı

Şifre, bağlantı dizesi ve JWT anahtarı **depoya konmaz**. Her geliştirici kendi bilgisayarında [User Secrets](https://learn.microsoft.com/aspnet/core/security/app-secrets) ile ayarlar:

```bash
cd api/DeskFlow.Api
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=deskflow_mobile;Username=postgres;Password=SIFRENIZ"
dotnet user-secrets set "Jwt:Key" "en-az-32-karakterlik-uzun-ve-rastgele-bir-anahtar-yazin"
dotnet user-secrets set "VarsayilanYonetici:Sifre" "yonetici1"
```

- `Jwt:Key`: JWT token'larını imzalayan gizli anahtar, **en az 32 karakter**. Ayarlanmazsa API başlamaz.
- İlk açılışta `Yonetici` ve `Ogrenci` rolleri ile `yonetici@deskflow.local` adresli yönetici hesabı otomatik oluşturulur.

### Kimlik doğrulama uç noktaları

| Yöntem | Adres | Açıklama |
|---|---|---|
| POST | `/api/auth/kayit` | Öğrenci olarak kayıt olur, token döner |
| POST | `/api/auth/giris` | E-posta ve şifreyle giriş, token döner |
| GET | `/api/auth/ben` | Token sahibinin bilgileri (`Authorization: Bearer <token>`) |

İstekler `api/DeskFlow.Api/DeskFlow.Api.http` dosyasından VS Code **REST Client** eklentisiyle denenebilir.

### Migration ve çalıştırma

```bash
dotnet ef database update
dotnet run
```

API `http://localhost:5137` adresinde çalışır. Swagger: `http://localhost:5137/swagger`

> Not: `IlkMigration` ile `AspNetUsers`, `Salonlar`, `Masalar`, `Rezervasyonlar` ve `CheckInKayitlari` tabloları oluşturulur; örnek olarak 2 salon ve 10 masa eklenir.

---

## 2. Mobil uygulama (`mobile/`)

### Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install) – stable kanal, **3.x** (`flutter --version` ile kontrol edin)
- Android Studio ve bir Android emülatörü (ya da USB hata ayıklaması açık bir Android telefon)

### Çalıştırma

```bash
cd mobile
flutter pub get
flutter run
```

### API adresinin ayarlanması

Adres `mobile/lib/core/config.dart` içindedir ve çalıştırırken değiştirilebilir:

| Ortam | Komut |
|---|---|
| Android emülatörü (varsayılan) | `flutter run` → `http://10.0.2.2:5137` |
| Gerçek Android cihaz | `flutter run --dart-define=API_BASE_URL=http://BILGISAYAR_IP:5137` |

Gerçek cihazda telefon ve bilgisayar aynı Wi-Fi ağında olmalıdır; bilgisayarın IP adresi `ipconfig` ile bulunur.

### Test

```bash
flutter analyze
flutter test
```

---

## Çalışma kuralları

- Herkes kendi GitHub hesabıyla commit ve push yapar.
- Her iş ayrı dalda yapılır (`isim/is-adi`) ve `main`'e Pull Request ile girer.
- İşe başlamadan önce `git checkout main` ve `git pull`.
- Şifre, bağlantı dizesi, JWT anahtarı gibi bilgiler asla commit edilmez.
