class WeatherConfig {
  WeatherConfig._();

  static const String apiHost = 'api.openweathermap.org';
  static const String defaultCity = 'Addis Ababa';
  static const String units = 'metric';

  static const String apiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '',
  );

  static bool get hasApiKey => apiKey.isNotEmpty;
}
