/// Глобальная конфигурация приложения.
class AppConfig {
  /// Базовый URL API. Переопределяется через:
  ///   flutter run --dart-define=API_BASE=https://api.example.com
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8000',
  );
}
