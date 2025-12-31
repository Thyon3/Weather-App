import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/weather_config.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  final service = WeatherService();
  ref.onDispose(service.dispose);
  return service;
});

final cityQueryProvider = StateProvider<String>((ref) {
  return WeatherConfig.defaultCity;
});

final weatherNotifierProvider =
    AutoDisposeAsyncNotifierProvider<WeatherNotifier, WeatherBundle>(
  WeatherNotifier.new,
);

class WeatherNotifier extends AutoDisposeAsyncNotifier<WeatherBundle> {
  @override
  Future<WeatherBundle> build() async {
    final city = ref.watch(cityQueryProvider);
    return _fetch(city);
  }

  Future<void> refresh() async {
    final currentCity = ref.read(cityQueryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(currentCity));
  }

  void updateCity(String city) {
    state = const AsyncLoading();
    ref.read(cityQueryProvider.notifier).state = city;
  }

  Future<WeatherBundle> _fetch(String city) async {
    final service = ref.read(weatherServiceProvider);
    return service.fetchWeather(city: city);
  }
}
