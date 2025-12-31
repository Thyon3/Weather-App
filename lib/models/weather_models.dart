class WeatherCondition {
  WeatherCondition({
    required this.label,
    required this.description,
    required this.iconCode,
  });

  final String label;
  final String description;
  final String iconCode;

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      label: json['main'] as String? ?? '—',
      description: json['description'] as String? ?? '',
      iconCode: json['icon'] as String? ?? '01d',
    );
  }

  String get sentenceCaseDescription {
    if (description.isEmpty) return label;
    return description[0].toUpperCase() + description.substring(1);
  }
}

class CurrentWeather {
  CurrentWeather({
    required this.city,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.pressure,
    required this.sunrise,
    required this.sunset,
    required this.condition,
    required this.observationTime,
    required this.timezoneOffset,
  });

  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int visibility;
  final int pressure;
  final DateTime sunrise;
  final DateTime sunset;
  final WeatherCondition condition;
  final DateTime observationTime;
  final int timezoneOffset;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final sys = json['sys'] as Map<String, dynamic>? ?? {};
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final timezoneOffset = (json['timezone'] as num?)?.toInt() ?? 0;

    return CurrentWeather(
      city: json['name'] as String? ?? '—',
      country: sys['country'] as String? ?? '',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      visibility: (json['visibility'] as num?)?.toInt() ?? 0,
      pressure: (main['pressure'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      sunrise: _toLocalTime(sys['sunrise'], timezoneOffset),
      sunset: _toLocalTime(sys['sunset'], timezoneOffset),
      observationTime: _toLocalTime(json['dt'], timezoneOffset),
      condition: weatherList.isNotEmpty
          ? WeatherCondition.fromJson(
              weatherList.first as Map<String, dynamic>,
            )
          : WeatherCondition(label: 'Unknown', description: '', iconCode: '01d'),
      timezoneOffset: timezoneOffset,
    );
  }

  static DateTime _toLocalTime(dynamic epochSeconds, int offsetSeconds) {
    final seconds = (epochSeconds as num?)?.toInt() ?? 0;
    final utc = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
    return utc.add(Duration(seconds: offsetSeconds));
  }
}

class HourlyForecast {
  HourlyForecast({
    required this.timestamp,
    required this.temperature,
    required this.condition,
    required this.pop,
  });

  final DateTime timestamp;
  final double temperature;
  final WeatherCondition condition;
  final double pop;

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    return HourlyForecast(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int? ?? 0) * 1000,
        isUtc: true,
      ),
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0,
      pop: (json['pop'] as num?)?.toDouble() ?? 0,
      condition: weatherList.isNotEmpty
          ? WeatherCondition.fromJson(weatherList.first as Map<String, dynamic>)
          : WeatherCondition(label: 'Unknown', description: '', iconCode: '01d'),
    );
  }
}

class WeatherBundle {
  WeatherBundle({
    required this.current,
    required this.hourly,
  });

  final CurrentWeather current;
  final List<HourlyForecast> hourly;

  WeatherBundle copyWith({
    CurrentWeather? current,
    List<HourlyForecast>? hourly,
  }) {
    return WeatherBundle(
      current: current ?? this.current,
      hourly: hourly ?? this.hourly,
    );
  }
}
