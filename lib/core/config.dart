/// Uygulama genelindeki ayarlar.
///
/// API adresi derleme sırasında değiştirilebilir:
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5137
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5137',
  );
}
