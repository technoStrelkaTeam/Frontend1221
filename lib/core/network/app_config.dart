class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
  });

  /// Пример: `https://api.company.ru` или `http://10.0.2.2:8080` (Android emulator).
  final String apiBaseUrl;

  static const AppConfig defaults = AppConfig(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.60.63.153:8080',
    ),
  );
}
//http://10.60.63.153:8080/',

