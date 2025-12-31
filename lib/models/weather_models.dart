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
    required this.latitude,
    required this.longitude,
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
  final double latitude;
  final double longitude;
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
    final coord = json['coord'] as Map<String, dynamic>? ?? {};
    final timezoneOffset = (json['timezone'] as num?)?.toInt() ?? 0;

    return CurrentWeather(
      city: json['name'] as String? ?? '—',
      country: sys['country'] as String? ?? '',
      latitude: (coord['lat'] as num?)?.toDouble() ?? 0,
      longitude: (coord['lon'] as num?)?.toDouble() ?? 0,
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      visibility: (json['visibility'] as num?)?.toInt() ?? 0,
      pressure: (main['pressure'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      sunrise: _toLocalTime(sys['sunrise'], timezoneOffset),
      sunset: _toLocalTime(sys['sunset'], timezoneOffset),
      observationTime: _toLocalTime(json['dt'], timezoneOffset),
      condition:
          weatherList.isNotEmpty
              ? WeatherCondition.fromJson(
                weatherList.first as Map<String, dynamic>,
              )
              : WeatherCondition(
                label: 'Unknown',
                description: '',
                iconCode: '01d',
              ),
      timezoneOffset: timezoneOffset,
    );
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

  factory HourlyForecast.fromJson(
    Map<String, dynamic> json,
    int timezoneOffset,
  ) {
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    return HourlyForecast(
      timestamp: _toLocalTime(json['dt'], timezoneOffset),
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0,
      pop: (json['pop'] as num?)?.toDouble() ?? 0,
      condition:
          weatherList.isNotEmpty
              ? WeatherCondition.fromJson(
                weatherList.first as Map<String, dynamic>,
              )
              : WeatherCondition(
                label: 'Unknown',
                description: '',
                iconCode: '01d',
              ),
    );
  }
}

class DailyForecast {
  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.pop,
  });

  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final WeatherCondition condition;
  final double pop;
}

class AirQuality {
  AirQuality({
    required this.index,
    required this.pm25,
    required this.pm10,
    required this.ozone,
    required this.no2,
  });

  final int index;
  final double pm25;
  final double pm10;
  final double ozone;
  final double no2;

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>? ?? [];
    if (list.isEmpty) {
      return AirQuality(index: 1, pm25: 0, pm10: 0, ozone: 0, no2: 0);
    }
    final main =
        (list.first as Map<String, dynamic>)['main'] as Map<String, dynamic>? ??
        {};
    final components =
        (list.first as Map<String, dynamic>)['components']
            as Map<String, dynamic>? ??
        {};
    return AirQuality(
      index: (main['aqi'] as num?)?.toInt() ?? 1,
      pm25: (components['pm2_5'] as num?)?.toDouble() ?? 0,
      pm10: (components['pm10'] as num?)?.toDouble() ?? 0,
      ozone: (components['o3'] as num?)?.toDouble() ?? 0,
      no2: (components['no2'] as num?)?.toDouble() ?? 0,
    );
  }

  String get category {
    switch (index) {
      case 1:
        return 'Excellent';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }
}

class WeatherBundle {
  WeatherBundle({
    required this.current,
    required this.hourly,
    required this.daily,
    this.airQuality,
    this.alerts = const [],
  });

  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final AirQuality? airQuality;
  final List<WeatherAlert> alerts;

  WeatherBundle copyWith({
    CurrentWeather? current,
    List<HourlyForecast>? hourly,
    List<DailyForecast>? daily,
    AirQuality? airQuality,
    List<WeatherAlert>? alerts,
  }) {
    return WeatherBundle(
      current: current ?? this.current,
      hourly: hourly ?? this.hourly,
      daily: daily ?? this.daily,
      airQuality: airQuality ?? this.airQuality,
      alerts: alerts ?? this.alerts,
    );
  }
}

class WeatherAlert {
  WeatherAlert({
    required this.event,
    required this.description,
    required this.severity,
    required this.sender,
    required this.start,
    required this.end,
  });

  final String event;
  final String description;
  final String severity;
  final String sender;
  final DateTime start;
  final DateTime end;

  factory WeatherAlert.fromJson(Map<String, dynamic> json, int timezoneOffset) {
    return WeatherAlert(
      event: json['event'] as String? ?? 'Weather alert',
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'moderate',
      sender: json['sender_name'] as String? ?? 'Weather service',
      start: _toLocalTime(json['start'], timezoneOffset),
      end: _toLocalTime(json['end'], timezoneOffset),
    );
  }
}

DateTime _toLocalTime(dynamic epochSeconds, int offsetSeconds) {
  final seconds = (epochSeconds as num?)?.toInt() ?? 0;
  final utc = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  return utc.add(Duration(seconds: offsetSeconds));
}
