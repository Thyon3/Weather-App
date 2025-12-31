import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Theme/theme.dart';
import '../models/weather_models.dart';
import '../provider/theme_provider.dart';
import '../provider/weather_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _cityController.text = ref.read(cityQueryProvider);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final trimmed = _cityController.text.trim();
    if (trimmed.isEmpty) return;
    ref.read(weatherNotifierProvider.notifier).updateCity(trimmed);
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final themeProviderLocal = ref.watch(themeProvider);
    final themeProvidreRead = ref.read(themeProvider.notifier);
    final isLight = themeProviderLocal == ThemeMode.light;
    final weatherState = ref.watch(weatherNotifierProvider);
    final city = ref.watch(cityQueryProvider);
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
              colors: [
                Color(0xFF10121B),
                Color(0xFF1E1E2F),
              ],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () => ref.read(weatherNotifierProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              children: [
                _buildTopRow(context, isLight, themeProvidreRead),
                const SizedBox(height: 16),
                _buildSearchField(context),
                const SizedBox(height: 24),
                weatherState.when(
                  data: (bundle) => Column(
                    children: [
                      _CurrentConditionsCard(bundle: bundle),
                      const SizedBox(height: 20),
                      _InsightGrid(bundle: bundle),
                      const SizedBox(height: 24),
                      _HourlyForecastStrip(hourly: bundle.hourly),
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => _ErrorState(
                    message: err.toString(),
                    onRetry: () => ref.read(weatherNotifierProvider.notifier).refresh(),
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
      BuildContext context, bool isLight, ThemeProvider themeProvidreRead) {
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
              style: GoogleFonts.lato(
                color: Colors.white70,
                fontSize: 15,
              ),
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
      onSubmitted: (_) => _handleSearch(),
      style: GoogleFonts.lato(
        color: Colors.white,
        fontSize: 18,
      ),
      decoration: InputDecoration(
        hintText: 'Search city or zip',
        hintStyle: GoogleFonts.lato(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: IconButton(
          onPressed: _handleSearch,
          icon: const Icon(Icons.send, color: Colors.white70),
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
  const _CurrentConditionsCard({required this.bundle});

  final WeatherBundle bundle;

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
              Image.network(
                'https://openweathermap.org/img/wn/${current.condition.iconCode}@2x.png',
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: 48,
                ),
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
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.cloud,
                        color: Colors.white,
                      ),
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
            style: GoogleFonts.lato(
              color: Colors.white70,
              fontSize: 14,
            ),
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
