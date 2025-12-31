# Weather App

Flutter weather experience with live OpenWeather data, theming, and an onboarding splash.

## Features

- Animated splash screen that transitions into the main experience.
- Riverpod-powered state management with persisted light/dark theme preference.
- Search any city, pull-to-refresh, and auto-sync hourly forecasts.
- Current conditions card, insights grid (humidity, wind, visibility, pressure), and hourly strip.
- Graceful error state and offline-friendly UI fallbacks.

## Requirements

- Flutter 3.27+ (Dart 3.7+).
- An [OpenWeather](https://openweathermap.org/api) API key.

## Setup

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Run the app with your API key (replace `<KEY>`):

   ```bash
   flutter run --dart-define=WEATHER_API_KEY=<KEY>
   ```

   The key is injected at build time and used by `WeatherService`.

3. (Optional) Run tests:

   ```bash
   flutter test
   ```

## Project structure

```
lib/
├── Theme/                # Light/dark theme definitions
├── config/               # API host, defaults, env configuration
├── models/               # Weather domain models
├── provider/             # Riverpod providers and notifiers
├── services/             # OpenWeather HTTP service
└── views/                # UI screens and widgets
```

## Environment variables

Currently the only required value is `WEATHER_API_KEY`. Supply it via `--dart-define`
or your CI’s preferred mechanism. If the key is missing the UI will show an error
message prompting for configuration.
