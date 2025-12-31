import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dismissedAlertsKey = 'dismissed_alert_ids';
const _notifiedAlertsKey = 'notified_alert_ids';

class AlertPreferences {
  const AlertPreferences({
    required this.dismissed,
    required this.notified,
  });

  const AlertPreferences.empty()
      : dismissed = const <String>{},
        notified = const <String>{};

  final Set<String> dismissed;
  final Set<String> notified;

  AlertPreferences copyWith({
    Set<String>? dismissed,
    Set<String>? notified,
  }) {
    return AlertPreferences(
      dismissed: dismissed ?? this.dismissed,
      notified: notified ?? this.notified,
    );
  }
}

final alertPreferencesProvider =
    AsyncNotifierProvider<AlertPreferencesNotifier, AlertPreferences>(
  AlertPreferencesNotifier.new,
);

class AlertPreferencesNotifier extends AsyncNotifier<AlertPreferences> {
  @override
  Future<AlertPreferences> build() async {
    return _load();
  }

  Future<void> dismiss(String alertId) async {
    if (alertId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updatedSet = {...(state.value?.dismissed ?? {}), alertId};
    final updated = (state.value ?? const AlertPreferences.empty())
        .copyWith(dismissed: updatedSet);
    state = AsyncValue.data(updated);
    await prefs.setStringList(_dismissedAlertsKey, updatedSet.toList());
  }

  Future<void> markNotified(String alertId) async {
    if (alertId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updatedSet = {...(state.value?.notified ?? {}), alertId};
    final updated = (state.value ?? const AlertPreferences.empty())
        .copyWith(notified: updatedSet);
    state = AsyncValue.data(updated);
    await prefs.setStringList(_notifiedAlertsKey, updatedSet.toList());
  }

  Future<bool> hasNotified(String alertId) async {
    final current = state.value ?? await _load();
    return current.notified.contains(alertId);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    state = const AsyncValue.data(AlertPreferences.empty());
    await prefs.remove(_dismissedAlertsKey);
    await prefs.remove(_notifiedAlertsKey);
  }

  Future<AlertPreferences> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed =
        (prefs.getStringList(_dismissedAlertsKey) ?? <String>[]).toSet();
    final notified =
        (prefs.getStringList(_notifiedAlertsKey) ?? <String>[]).toSet();
    return AlertPreferences(
      dismissed: dismissed,
      notified: notified,
    );
  }
}
