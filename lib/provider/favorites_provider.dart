import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/weather_config.dart';
import '../utils/city_utils.dart';

const _favoritesKey = 'favorite_cities';

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<String>>(
      FavoritesNotifier.new,
    );

class FavoritesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_favoritesKey);
    if (stored == null || stored.isEmpty) {
      return [WeatherConfig.defaultCity];
    }
    return stored;
  }

  Future<void> toggle(String rawCity) async {
    final city = normalizeCity(rawCity);
    if (city.isEmpty) return;
    final current = [...(state.value ?? await _load())];
    if (current.contains(city)) {
      current.remove(city);
    } else {
      current.insert(0, city);
    }
    await _persist(current);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = [...(state.value ?? await _load())];
    if (oldIndex < 0 || oldIndex >= current.length) return;
    if (newIndex < 0 || newIndex >= current.length) {
      newIndex = current.length - 1;
    }
    if (oldIndex == newIndex) return;
    final city = current.removeAt(oldIndex);
    current.insert(newIndex, city);
    await _persist(current);
  }

  Future<void> promote(String rawCity) async {
    final city = normalizeCity(rawCity);
    if (city.isEmpty) return;
    final current = [...(state.value ?? await _load())];
    if (!current.contains(city)) return;
    current.remove(city);
    current.insert(0, city);
    await _persist(current);
  }

  Future<void> remove(String rawCity) async {
    final city = normalizeCity(rawCity);
    if (city.isEmpty) return;
    final current = [...(state.value ?? await _load())];
    current.remove(city);
    await _persist(current);
  }

  Future<List<String>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? <String>[];
  }

  Future<void> _persist(List<String> cities) async {
    state = AsyncValue.data(cities);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, cities);
  }
}
