                            label: const Text('Manage'),
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../Theme/theme.dart';
import '../models/weather_models.dart';
import '../provider/alert_preferences_provider.dart';
import '../provider/favorites_provider.dart';
import '../provider/recent_search_provider.dart';
import '../provider/theme_provider.dart';
import '../provider/weather_provider.dart';
import '../utils/city_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _DailyForecastList extends StatelessWidget {
  const _DailyForecastList({required this.daily});

  final List<DailyForecast> daily;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '5-day outlook',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...daily.map(
          (forecast) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('EEEE').format(forecast.date),
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Image.network(
                  'https://openweathermap.org/img/wn/${forecast.condition.iconCode}.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.cloud_queue, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  forecast.condition.sentenceCaseDescription,
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${forecast.maxTemp.toStringAsFixed(0)}° / ${forecast.minTemp.toStringAsFixed(0)}°',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(forecast.pop * 100).round()}% rain',
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.isVisible,
    required this.isLoading,
    required this.hasHistory,
    required this.suggestions,
    required this.query,
    required this.onSuggestionTap,
    required this.onClearHistory,
  });

  final bool isVisible;
  final bool isLoading;
  final bool hasHistory;
  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    if (isLoading) {
      return const LinearProgressIndicator(minHeight: 2);
    }
    if (suggestions.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          query.isEmpty
              ? 'Start searching to build your recent list.'
              : 'No matches yet—try another spelling.',
          style: GoogleFonts.lato(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              query.isEmpty ? 'Recent searches' : 'Suggestions',
              style: GoogleFonts.lato(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasHistory && query.isEmpty)
              TextButton(
                onPressed: onClearHistory,
                child: const Text('Clear all'),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ...suggestions.map(
          (city) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history, color: Colors.white54),
            title: Text(
              city,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(
              Icons.north_east,
              color: Colors.white54,
              size: 18,
            ),
            onTap: () => onSuggestionTap(city),
          ),
        ),
      ],
    );
  }
}

class _FavoritesStrip extends StatelessWidget {
  const _FavoritesStrip({
    required this.favorites,
    required this.onCitySelected,
    required this.onCityRemoved,
    required this.activeCity,
  });

  final List<String> favorites;
  final ValueChanged<String> onCitySelected;
  final ValueChanged<String> onCityRemoved;
  final String activeCity;

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Bookmark cities to jump back quickly.',
          style: GoogleFonts.lato(color: Colors.white70),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: favorites.map((city) {
          final normalized = normalizeCity(city);
          final isActive = normalizeCity(activeCity) == normalized;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InputChip(
              label: Text(
                city,
                style: GoogleFonts.lato(
                  color: isActive ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              avatar: Icon(
                Icons.location_on,
                color: isActive ? Colors.black : Colors.white70,
                size: 18,
              ),
              backgroundColor: Colors.white.withOpacity(0.08),
              selectedColor: const Color(0xFFFFBF00),
              selected: isActive,
              onPressed: () => onCitySelected(city),
              onDeleted: () => onCityRemoved(city),
              deleteIconColor: isActive ? Colors.black : Colors.white70,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _shimmerBox(height: 220),
        const SizedBox(height: 18),
        _shimmerGrid(),
        const SizedBox(height: 18),
        _shimmerStrip(),
      ],
    );
  }

  Future<void> _shareWeather(WeatherBundle bundle) async {
    final current = bundle.current;
    final hourly =
        bundle.hourly.isNotEmpty ? bundle.hourly.first : null;
    final buffer = StringBuffer()
      ..writeln(
        'Weather in ${current.city}, ${current.country} '
        '(${DateFormat('EEE, MMM d • h:mm a').format(current.observationTime)})',
      )
      ..writeln(
        '• Temp: ${current.temperature.toStringAsFixed(0)}° '
        '(feels like ${current.feelsLike.toStringAsFixed(0)}°)',
      )
      ..writeln(
        '• Condition: ${current.condition.sentenceCaseDescription}',
      )
      ..writeln(
        '• Humidity: ${current.humidity}%  |  Wind: ${current.windSpeed.toStringAsFixed(1)} m/s',
      );

    if (bundle.airQuality != null) {
      buffer.writeln(
        '• Air Quality: ${bundle.airQuality!.category} '
        '(PM2.5 ${bundle.airQuality!.pm25.toStringAsFixed(1)} µg/m³)',
      );
    }
    if (hourly != null) {
      buffer.writeln(
        'Next hour: ${hourly.temperature.toStringAsFixed(0)}° '
        'with ${(hourly.pop * 100).round()}% chance of rain',
      );
    }
    buffer.writeln('\nShared via Weather App ☀️🌧️');

    await Share.share(buffer.toString());
  }

  Future<void> _openFavoritesManager(
    List<String> favorites,
    String activeCity,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final managedList = List<String>.from(favorites);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B2C),
                borderRadius: BorderRadius.circular(28),
              ),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Manage favorites',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Drag to reorder, swipe to remove, or tap the star to set as default.',
                    style: GoogleFonts.lato(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (managedList.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No favorites yet. Search for a city and add it!',
                          style: GoogleFonts.lato(color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount: managedList.length,
                        buildDefaultDragHandles: false,
                        padding: EdgeInsets.zero,
                        onReorder: (oldIndex, newIndex) {
                          setModalState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final city = managedList.removeAt(oldIndex);
                            managedList.insert(newIndex, city);
                          });
                          ref
                              .read(favoritesProvider.notifier)
                              .reorder(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final cityName = managedList[index];
                          final normalizedActive = normalizeCity(activeCity);
                          final isActive =
                              normalizeCity(cityName) == normalizedActive;
                          return Dismissible(
                            key: ValueKey(cityName),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) {
                              setModalState(() {
                                managedList.removeAt(index);
                              });
                              ref
                                  .read(favoritesProvider.notifier)
                                  .remove(cityName);
                            },
                            child: Card(
                              color: Colors.white.withOpacity(0.05),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                leading: ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(Icons.drag_handle,
                                      color: Colors.white54),
                                ),
                                title: Text(
                                  cityName,
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontWeight:
                                        isActive ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                subtitle: isActive
                                    ? Text(
                                        'Active city',
                                        style: GoogleFonts.lato(
                                          color: Colors.lightBlueAccent,
                                          fontSize: 12,
                                        ),
                                      )
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.star,
                                        color: isActive
                                            ? Colors.yellowAccent
                                            : Colors.white38,
                                      ),
                                      tooltip: 'Set as default city',
                                      onPressed: () {
                                        ref
                                            .read(
                                                favoritesProvider.notifier)
                                            .promote(cityName);
                                        ref
                                            .read(cityQueryProvider.notifier)
                                            .state = cityName;
                                        ref
                                            .read(weatherNotifierProvider
                                                .notifier)
                                            .updateCity(cityName);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.white54),
                                      onPressed: () {
                                        setModalState(() {
                                          managedList.removeAt(index);
                                        });
                                        ref
                                            .read(favoritesProvider.notifier)
                                            .remove(cityName);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _shimmerBox({double height = 180}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  Widget _shimmerGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: List.generate(4, (_) => _shimmerBox(height: 110)),
    );
  }

  Widget _shimmerStrip() {
    return SizedBox(
      height: 140,
      child: Row(
        children: List.generate(
          4,
          (_) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _draftQuery = '';

  @override
  void initState() {
    super.initState();
    _cityController.text = ref.read(cityQueryProvider);
    _draftQuery = _cityController.text;
    _searchFocus.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _searchFocus.removeListener(_handleFocusChange);
    _cityController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final trimmed = _cityController.text.trim();
    if (trimmed.isEmpty) return;
    ref.read(weatherNotifierProvider.notifier).updateCity(trimmed);
    _searchFocus.unfocus();
    setState(() {
      _draftQuery = trimmed;
    });
    ref.read(recentSearchProvider.notifier).addEntry(trimmed);
    ref.read(favoritesProvider.notifier).toggle(trimmed);
  }

  void _handleFocusChange() {
    setState(() {});
  }

  void _onCityChanged(String value) {
    setState(() {
      _draftQuery = value;
    });
  }

  void _selectSuggestion(String city) {
    _cityController.text = city;
    _cityController.selection = TextSelection.fromPosition(
      TextPosition(offset: city.length),
    );
    setState(() {
      _draftQuery = city;
    });
    ref.read(weatherNotifierProvider.notifier).updateCity(city);
    ref.read(recentSearchProvider.notifier).addEntry(city);
    _searchFocus.unfocus();
  }

  String _alertId(WeatherAlert alert) =>
      '${alert.event}-${alert.start.millisecondsSinceEpoch}';

  List<String> _buildSuggestions(
    String query,
    List<String> favorites,
    List<String> recents,
  ) {
    final normalized = query.trim().toLowerCase();
    final ordered = [...favorites, ...recents];
    final seen = <String>{};
    final results = <String>[];
    if (normalized.isEmpty) {
      for (final city in recents) {
        final key = normalizeCity(city);
        if (seen.add(key)) {
          results.add(city);
        }
        if (results.length >= 6) break;
      }
      return results;
    }

    for (final city in ordered) {
      final key = normalizeCity(city);
      if (seen.contains(key)) continue;
      if (city.toLowerCase().contains(normalized)) {
        results.add(city);
        seen.add(key);
      }
      if (results.length >= 6) break;
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final themeProviderLocal = ref.watch(themeProvider);
    final themeProvidreRead = ref.read(themeProvider.notifier);
    final isLight = themeProviderLocal == ThemeMode.light;
    final weatherState = ref.watch(weatherNotifierProvider);
    final city = ref.watch(cityQueryProvider);
    final favoritesState = ref.watch(favoritesProvider);
    final favorites = favoritesState.value ?? const <String>[];
    final dismissedAlerts =
        ref.watch(alertPreferencesProvider).value ?? const <String>{};
    final recentState = ref.watch(recentSearchProvider);
    final recents = recentState.value ?? const <String>[];
    final suggestions = _buildSuggestions(_draftQuery, favorites, recents);
    final showSuggestions =
        recentState.isLoading || recents.isNotEmpty || suggestions.isNotEmpty;

    if (_cityController.text != city) {
      _cityController.text = city;
      _cityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _cityController.text.length),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF10121B), Color(0xFF1E1E2F)],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(weatherNotifierProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              children: [
                _buildTopRow(context, isLight, themeProvidreRead),
                const SizedBox(height: 16),
                _buildSearchField(context),
                const SizedBox(height: 12),
                _SuggestionList(
                  isVisible: showSuggestions,
                  isLoading: recentState.isLoading,
                  hasHistory: recents.isNotEmpty,
                  suggestions: suggestions,
                  query: _draftQuery,
                  onSuggestionTap: _selectSuggestion,
                  onClearHistory: () =>
                      ref.read(recentSearchProvider.notifier).clearAll(),
                ),
                const SizedBox(height: 12),
                favoritesState.when(
                  data: (favorites) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Favorites',
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _openFavoritesManager(
                              favorites,
                              city,
                            ),
                            icon: const Icon(
                              Icons.tune,
                              color: Colors.white70,
                              size: 18,
                            ),
                            label: const Text('Manage'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _FavoritesStrip(
                        favorites: favorites,
                        activeCity: city,
                        onCitySelected: (selected) {
                          _cityController.text = selected;
                          _cityController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: selected.length),
                          );
                          ref
                              .read(weatherNotifierProvider.notifier)
                              .updateCity(selected);
                        },
                        onCityRemoved: (entry) => ref
                            .read(favoritesProvider.notifier)
                            .remove(entry),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(
                    height: 32,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LinearProgressIndicator(minHeight: 4),
                    ),
                  ),
                  error: (_, __) => const Text(
                    'Unable to load favorites',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 24),
                weatherState.when(
                  data: (bundle) {
                    final isFavoriteCity = favorites
                        .map(normalizeCity)
                        .contains(normalizeCity(bundle.current.city));
                    final activeAlerts = bundle.alerts
                        .where(
                          (alert) => !dismissedAlerts.contains(
                            _alertId(alert),
                          ),
                        )
                        .toList();
                    return Column(
                      children: [
                        _CurrentConditionsCard(
                          bundle: bundle,
                          isFavorite: isFavoriteCity,
                          onFavoriteTap: () => ref
                              .read(favoritesProvider.notifier)
                              .toggle(bundle.current.city),
                          onShareTap: () => _shareWeather(bundle),
                        ),
                        const SizedBox(height: 20),
                        _InsightGrid(bundle: bundle),
                        if (activeAlerts.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _AlertsPanel(
                            alerts: activeAlerts,
                            onDismissed: (alert) {
                              ref
                                  .read(alertPreferencesProvider.notifier)
                                  .dismiss(_alertId(alert));
                            },
                          ),
                        ],
                        if (bundle.airQuality != null) ...[
                          const SizedBox(height: 20),
                          _AirQualityCard(airQuality: bundle.airQuality!),
                        ],
                        const SizedBox(height: 24),
                        _HourlyForecastStrip(hourly: bundle.hourly),
                        if (bundle.daily.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _DailyForecastList(daily: bundle.daily),
                        ],
                      ],
                    );
                  },
                  loading: () => const _LoadingState(),
                  error: (err, stack) => _ErrorState(
                    message: err.toString(),
                    onRetry: () =>
                        ref.read(weatherNotifierProvider.notifier).refresh(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(
    BuildContext context,
    bool isLight,
    ThemeProvider themeProvidreRead,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Stay ahead with live updates',
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: themeProvidreRead.toggleTheme,
          icon: Icon(
            isLight ? Icons.nightlight_round : Icons.wb_sunny,
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _cityController,
      focusNode: _searchFocus,
      textInputAction: TextInputAction.search,
      onChanged: _onCityChanged,
      onSubmitted: (_) => _handleSearch(),
      style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        hintText: 'Search city or zip',
        hintStyle: GoogleFonts.lato(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: IconButton(
          onPressed: _handleSearch,
          icon: const Icon(Icons.send, color: Colors.white70),
          tooltip: 'Search city',
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CurrentConditionsCard extends StatelessWidget {
  const _CurrentConditionsCard({
    required this.bundle,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onShareTap,
  });

  final WeatherBundle bundle;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('EEE, MMM d • h:mm a');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final current = bundle.current;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.city}, ${current.country}',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(current.observationTime),
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onShareTap,
                    icon: const Icon(
                      Icons.ios_share,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: 'Share forecast',
                  ),
                  IconButton(
                    onPressed: onFavoriteTap,
                    icon: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 28,
                    ),
                    tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
                  ),
                ],
              ),
              Image.network(
                'https://openweathermap.org/img/wn/${current.condition.iconCode}@2x.png',
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.wb_sunny, color: Colors.white, size: 48),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${current.temperature.toStringAsFixed(0)}°',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            current.condition.sentenceCaseDescription,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(
                label: 'Feels like',
                value: '${current.feelsLike.toStringAsFixed(0)}°',
              ),
              _MiniStat(
                label: 'Sunrise',
                value: DateFormat('h:mm a').format(current.sunrise),
              ),
              _MiniStat(
                label: 'Sunset',
                value: DateFormat('h:mm a').format(current.sunset),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InsightGrid extends StatelessWidget {
  const _InsightGrid({required this.bundle});

  final WeatherBundle bundle;

  @override
  Widget build(BuildContext context) {
    final current = bundle.current;
    final tiles = [
      _InsightTileData(
        title: 'Humidity',
        value: '${current.humidity}%',
        icon: Icons.water_drop,
      ),
      _InsightTileData(
        title: 'Wind',
        value: '${current.windSpeed.toStringAsFixed(1)} m/s',
        icon: Icons.air,
      ),
      _InsightTileData(
        title: 'Visibility',
        value: '${(current.visibility / 1000).toStringAsFixed(1)} km',
        icon: Icons.remove_red_eye,
      ),
      _InsightTileData(
        title: 'Pressure',
        value: '${current.pressure} hPa',
        icon: Icons.speed,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 120,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) => _InsightTile(data: tiles[index]),
    );
  }
}

class _InsightTileData {
  _InsightTileData({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.data});

  final _InsightTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: Colors.white, size: 30),
          const Spacer(),
          Text(
            data.title,
            style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AirQualityCard extends StatelessWidget {
  const _AirQualityCard({required this.airQuality});

  final AirQuality airQuality;

  Color _badgeColor(int index) {
    switch (index) {
      case 1:
        return const Color(0xFF20bf55);
      case 2:
        return const Color(0xFF78c091);
      case 3:
        return const Color(0xFFF4d35e);
      case 4:
        return const Color(0xFFF06543);
      case 5:
        return const Color(0xFFb61919);
      default:
        return Colors.grey;
    }
  }

  String _healthTip(int index) {
    switch (index) {
      case 1:
        return 'Breath easy—ideal air for outdoor workouts.';
      case 2:
        return 'Great for most people; keep ventilation flowing indoors.';
      case 3:
        return 'Sensitive groups should limit prolonged outdoor exertion.';
      case 4:
        return 'Cut back on outdoor time; consider masks if you head out.';
      case 5:
        return 'Stay indoors when possible and use air purifiers.';
      default:
        return 'Monitor conditions and take precautions as needed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _badgeColor(airQuality.index);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Air Quality',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: badgeColor),
                    const SizedBox(width: 6),
                    Text(
                      airQuality.category,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _healthTip(airQuality.index),
            style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PollutantStat(
                label: 'PM2.5',
                value: '${airQuality.pm25.toStringAsFixed(1)} µg/m³',
              ),
              _PollutantStat(
                label: 'PM10',
                value: '${airQuality.pm10.toStringAsFixed(1)} µg/m³',
              ),
              _PollutantStat(
                label: 'O₃',
                value: '${airQuality.ozone.toStringAsFixed(0)} µg/m³',
              ),
              _PollutantStat(
                label: 'NO₂',
                value: '${airQuality.no2.toStringAsFixed(0)} µg/m³',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PollutantStat extends StatelessWidget {
  const _PollutantStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel({
    required this.alerts,
    required this.onDismissed,
  });

  final List<WeatherAlert> alerts;
  final ValueChanged<WeatherAlert> onDismissed;

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return const Color(0xFFB00020);
      case 'severe':
        return const Color(0xFFE65100);
      case 'moderate':
        return const Color(0xFFFBC02D);
      case 'minor':
        return const Color(0xFF66BB6A);
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alerts.map((alert) {
        final color = _severityColor(alert.severity);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.event,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onDismissed(alert),
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Issued by ${alert.sender}',
                style: GoogleFonts.lato(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                alert.description,
                style: GoogleFonts.lato(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.white54, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${DateFormat('EEE HH:mm').format(alert.start)} → ${DateFormat('EEE HH:mm').format(alert.end)}',
                    style: GoogleFonts.lato(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _HourlyForecastStrip extends StatelessWidget {
  const _HourlyForecastStrip({required this.hourly});

  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next hours',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hourly.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final forecast = hourly[index];
              return Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('ha').format(forecast.timestamp.toLocal()),
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Image.network(
                      'https://openweathermap.org/img/wn/${forecast.condition.iconCode}.png',
                      width: 50,
                      height: 50,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.cloud, color: Colors.white),
                    ),
                    Text(
                      '${forecast.temperature.toStringAsFixed(0)}°',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(forecast.pop * 100).round()}% rain',
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off, color: Colors.white.withOpacity(0.7), size: 48),
          const SizedBox(height: 16),
          Text(
            'Unable to load weather data',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
