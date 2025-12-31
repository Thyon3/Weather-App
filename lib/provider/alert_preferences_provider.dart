import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dismissedAlertsKey = 'dismissed_alert_ids';

final alertPreferencesProvider =
    AsyncNotifierProvider<AlertPreferencesNotifier, Set<String>>(
  AlertPreferencesNotifier.new,
);

class AlertPreferencesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_dismissedAlertsKey) ?? <String>[];
    return stored.toSet();
  }

  Future<void> dismiss(String alertId) async {
    if (alertId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = {...(state.value ?? await _load()), alertId};
    state = AsyncValue.data(updated);
    await prefs.setStringList(_dismissedAlertsKey, updated.toList());
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    state = const AsyncValue.data(<String>{});
    await prefs.remove(_dismissedAlertsKey);
  }

  Future<Set<String>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_dismissedAlertsKey) ?? <String>[]).toSet();
  }
}
