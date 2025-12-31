import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/city_utils.dart';

const _recentKey = 'recent_cities';
const _maxRecentEntries = 8;

final recentSearchProvider =
    AsyncNotifierProvider<RecentSearchNotifier, List<String>>(
      RecentSearchNotifier.new,
    );

class RecentSearchNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentKey) ?? <String>[];
  }

  Future<void> addEntry(String rawCity) async {
    final city = normalizeCity(rawCity);
    if (city.isEmpty) return;
    final current = [...(state.value ?? await _load())];
    current.remove(city);
    current.insert(0, city);
    while (current.length > _maxRecentEntries) {
      current.removeLast();
    }
    await _persist(current);
  }

  Future<void> clearAll() async {
    state = const AsyncValue.data(<String>[]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
  }

  Future<List<String>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentKey) ?? <String>[];
  }

  Future<void> _persist(List<String> cities) async {
    state = AsyncValue.data(cities);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, cities);
  }
}
