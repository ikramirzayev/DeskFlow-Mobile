/// Uygulama genelindeki ayarlar.
///
/// Varsayılan adres Android emülatörü içindir (10.0.2.2 = bilgisayarın localhost'u).
/// Gerçek cihazda bilgisayarın ağ IP adresi verilir:
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.20:5137
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5137',
  );
}
