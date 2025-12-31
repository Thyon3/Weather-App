import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/weather_config.dart';
import '../models/weather_models.dart';

class WeatherException implements Exception {
  WeatherException(this.message);

  final String message;

  @override
  String toString() => 'WeatherException: $message';
}

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherBundle> fetchWeather({required String city}) async {
    if (!WeatherConfig.hasApiKey) {
      throw WeatherException(
        'Missing OpenWeather API key. Pass WEATHER_API_KEY via --dart-define.',
      );
    }

    final normalizedCity =
        city.trim().isEmpty ? WeatherConfig.defaultCity : city.trim();

    final currentJson = await _get(
      path: '/data/2.5/weather',
      queryParameters: _baseQuery(normalizedCity),
    );

    final forecastJson = await _get(
      path: '/data/2.5/forecast',
      queryParameters: _baseQuery(normalizedCity),
    );

    final current = CurrentWeather.fromJson(currentJson);
    final hourly = (forecastJson['list'] as List<dynamic>? ?? [])
        .map((item) => HourlyForecast.fromJson(item as Map<String, dynamic>))
        .take(12)
        .toList();

    return WeatherBundle(
      current: current,
      hourly: hourly,
    );
  }

  Map<String, String> _baseQuery(String city) {
    return {
      'q': city,
      'appid': WeatherConfig.apiKey,
      'units': WeatherConfig.units,
    };
  }

  Future<Map<String, dynamic>> _get({
    required String path,
    required Map<String, String> queryParameters,
  }) async {
    final uri = Uri.https(WeatherConfig.apiHost, path, queryParameters);
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw WeatherException(_humanizeError(response));
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _humanizeError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final message = body['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return message;
      }
    } catch (_) {}
    return 'Request failed with status ${response.statusCode}.';
  }

  void dispose() {
    _client.close();
  }
}
