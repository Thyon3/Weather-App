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

    final alertsJson = await _get(
      path: '/data/2.5/onecall',
      queryParameters: {
        'lat': currentJson['coord']?['lat'].toString() ?? '0',
        'lon': currentJson['coord']?['lon'].toString() ?? '0',
        'appid': WeatherConfig.apiKey,
        'exclude': 'current,minutely,hourly,daily',
      },
    );

    final current = CurrentWeather.fromJson(currentJson);
    final timezoneOffset = current.timezoneOffset;

    final forecastList =
        (forecastJson['list'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();

    final hourly =
        forecastList
            .map((item) => HourlyForecast.fromJson(item, timezoneOffset))
            .take(12)
            .toList();

    final daily = _buildDailyForecast(forecastList, timezoneOffset);
    final airQuality = await _fetchAirQuality(
      lat: current.latitude,
      lon: current.longitude,
    );
    final alerts =
        (alertsJson['alerts'] as List<dynamic>? ?? [])
            .map(
              (entry) => WeatherAlert.fromJson(
                entry as Map<String, dynamic>,
                timezoneOffset,
              ),
            )
            .toList();

    return WeatherBundle(
      current: current,
      hourly: hourly,
      daily: daily,
      airQuality: airQuality,
      alerts: alerts,
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

  List<DailyForecast> _buildDailyForecast(
    List<Map<String, dynamic>> entries,
    int timezoneOffset,
  ) {
    final grouped = <DateTime, List<Map<String, dynamic>>>{};
    for (final entry in entries) {
      final timestamp = _localDate(_toLocalTime(entry['dt'], timezoneOffset));
      grouped.putIfAbsent(timestamp, () => []).add(entry);
    }

    final daily =
        grouped.entries.map((entry) {
            final readings = entry.value;
            double minTemp = double.infinity;
            double maxTemp = -double.infinity;
            double avgPop = 0;
            Map<String, dynamic>? rep;

            for (final reading in readings) {
              final main = reading['main'] as Map<String, dynamic>? ?? {};
              final tempMin = (main['temp_min'] as num?)?.toDouble();
              final tempMax = (main['temp_max'] as num?)?.toDouble();
              if (tempMin != null) {
                minTemp =
                    minTemp.isFinite
                        ? (tempMin < minTemp ? tempMin : minTemp)
                        : tempMin;
              }
              if (tempMax != null) {
                maxTemp =
                    maxTemp.isFinite
                        ? (tempMax > maxTemp ? tempMax : maxTemp)
                        : tempMax;
              }
              avgPop += (reading['pop'] as num?)?.toDouble() ?? 0;
            }

            avgPop = readings.isEmpty ? 0 : avgPop / readings.length;

            rep = _representativeReading(readings, timezoneOffset);

            return DailyForecast(
              date: entry.key,
              minTemp: minTemp.isFinite ? minTemp : 0,
              maxTemp: maxTemp.isFinite ? maxTemp : 0,
              condition:
                  rep != null
                      ? WeatherCondition.fromJson(
                        (rep['weather'] as List<dynamic>).first
                            as Map<String, dynamic>,
                      )
                      : WeatherCondition(
                        label: 'Unknown',
                        description: '',
                        iconCode: '01d',
                      ),
              pop: avgPop,
            );
          }).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return daily.take(5).toList();
  }

  Map<String, dynamic>? _representativeReading(
    List<Map<String, dynamic>> readings,
    int timezoneOffset,
  ) {
    if (readings.isEmpty) return null;
    readings.sort((a, b) {
      final diffA = (_toLocalTime(a['dt'], timezoneOffset).hour - 12).abs();
      final diffB = (_toLocalTime(b['dt'], timezoneOffset).hour - 12).abs();
      return diffA.compareTo(diffB);
    });
    return readings.firstWhere(
      (entry) => (entry['weather'] as List<dynamic>?)?.isNotEmpty ?? false,
      orElse: () => readings.first,
    );
  }

  DateTime _localDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime _toLocalTime(dynamic epochSeconds, int offsetSeconds) {
    final seconds = (epochSeconds as num?)?.toInt() ?? 0;
    final utc = DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    );
    return utc.add(Duration(seconds: offsetSeconds));
  }

  Future<AirQuality?> _fetchAirQuality({
    required double lat,
    required double lon,
  }) async {
    if (lat == 0 && lon == 0) return null;
    try {
      final response = await _get(
        path: '/data/2.5/air_pollution',
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'appid': WeatherConfig.apiKey,
        },
      );
      return AirQuality.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
