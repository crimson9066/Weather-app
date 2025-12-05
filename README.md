# Weather App

A Flutter weather application that displays real-time weather data for any city worldwide using the OpenWeatherMap API.

## Features

- Search for weather by city name with autocomplete suggestions
- View comprehensive weather information including temperature, humidity, wind speed, and more
- Save favorite cities for quick access
- Toggle between Celsius and Fahrenheit
- View recent search history
- Clean, responsive user interface
- Works on Windows, iOS, and Android

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or later
- An OpenWeatherMap API key (free tier available at https://openweathermap.org/api)

### Setup

1. Get an OpenWeatherMap API key:
   - Visit https://openweathermap.org/api
   - Create a free account and generate an API key

2. Configure the API key:
   - Open `lib/constants/api_config.dart`
   - Replace `YOUR_API_KEY_HERE` with your actual API key

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run -d windows  # for Windows
   flutter run             # for default device
   ```

## Project Structure

```
lib/
├── main.dart                      # App entry point and main navigation
├── pages/                         # App screens
│   ├── home_screen.dart          # Search and home page
│   ├── weather_details_screen.dart # Detailed weather view
│   ├── favorites_screen.dart      # Saved favorite cities
│   └── settings_screen.dart       # App settings
├── services/                      # API and data management
│   ├── weather_service.dart      # Weather API integration
│   ├── geocoding_service.dart    # City name lookup and suggestions
│   └── storage_service.dart      # Local data persistence
├── models/                        # Data structures
│   └── weather_model.dart        # Weather data model
├── providers/                     # State management (Riverpod)
│   └── weather_providers.dart    # Weather state providers
├── widgets/                       # Reusable UI components
│   └── reusable_widgets.dart     # Common widgets
└── constants/                     # Configuration
    └── api_config.dart           # API settings
```

## How It Works

The app uses Riverpod for state management and relies on two main APIs:

- **OpenWeatherMap Current Weather API**: Provides real-time weather data for a given city
- **OpenWeatherMap Geocoding API**: Provides city name suggestions as you type

All user preferences and search history are stored locally on the device using SharedPreferences.

