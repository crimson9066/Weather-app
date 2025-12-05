# Weather App - Flutter Multi-Page Weather Application

A comprehensive multi-page Flutter mobile application that retrieves and displays real-time weather data using the OpenWeatherMap Current Weather API.

## Features

- **Search Weather**: Search for any city worldwide to get current weather information
- **Detailed Weather Information**:
  - Current temperature (with "Feels Like")
  - Weather description and main condition
  - Humidity and wind speed
  - Sunrise and sunset times with local timezone support
  - Weather icons from OpenWeatherMap API
  - Local time display

- **Favorites Management**: Save your favorite cities for quick access
- **Customizable Settings**: Toggle between Celsius and Fahrenheit temperature units
- **Search History**: View and quickly access your recent searches
- **Responsive UI**: Clean, modern interface optimized for mobile devices
- **Robust Error Handling**:
  - Network connectivity checks
  - Invalid city name validation
  - API error handling (401, 404, and more)
  - Loading indicators for better UX

## Architecture

### Folder Structure

```
lib/
├── main.dart                 # Application entry point
├── pages/                    # Screen pages
│   ├── home_screen.dart      # Search and home screen
│   ├── weather_details_screen.dart  # Weather details view
│   ├── favorites_screen.dart # Favorites management
│   └── settings_screen.dart  # App settings
├── services/                 # Business logic
│   ├── weather_service.dart  # OpenWeatherMap API integration
│   └── storage_service.dart  # Local storage (SharedPreferences)
├── models/                   # Data models
│   └── weather_model.dart    # Weather data structure
├── providers/                # Riverpod state management
│   └── weather_providers.dart # Weather-related providers
├── widgets/                  # Reusable widgets
│   └── reusable_widgets.dart # Common UI components
└── constants/                # Configuration
    └── api_config.dart       # API configuration
```

### Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod 2.x
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences
- **Date/Time**: intl package
- **Navigation**: Material Navigation with MaterialPageRoute

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart (>=3.0.0)
- An OpenWeatherMap API key (free tier available)

### Installation

1. **Clone the repository** (if using GitHub):
```bash
git clone <repository-url>
cd weather_app
```

2. **Get dependencies**:
```bash
flutter pub get
```

3. **Configure API Key**:
   - Open `lib/constants/api_config.dart`
   - Replace `'YOUR_API_KEY_HERE'` with your actual OpenWeatherMap API key
   - Get your API key from: https://openweathermap.org/api

Example:
```dart
class ApiConfig {
  static const String apiKey = 'your_actual_api_key_here';
  // ...
}
```

### Running the App

**Development Mode**:
```bash
flutter run
```

**Release Build**:
```bash
flutter run --release
```

### Building APK (Android)

**Debug APK**:
```bash
flutter build apk
```

**Release APK**:
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### Building for iOS

```bash
flutter build ios
```

For detailed iOS build instructions, see [iOS Build Guide](https://flutter.dev/docs/deployment/ios)

## Project Requirements Met

### Application Architecture
- Multi-page Flutter application with 4 screens
- Navigator-based routing using MaterialPageRoute
- Clean separation of concerns

### Functional Requirements
1. **Home/Search Screen**: City search with search history
2. **Weather Details Screen**: Comprehensive weather information display
3. **Favorites Screen**: Save and manage favorite cities
4. **Settings Screen**: Temperature unit configuration

### Technical Requirements
- OpenWeatherMap API integration (by city name and coordinates)
- Riverpod for state management
- SharedPreferences for local data persistence
- Comprehensive error handling
- Responsive, clean UI with weather icons
- Proper folder structure and code organization
- API key configuration (not hardcoded)

## API Reference

This app uses the **OpenWeatherMap Current Weather Data API**:
- Documentation: https://openweathermap.org/current
- Free tier: 60 calls/minute, 1,000,000 calls/month

### Endpoints Used

- By city name: `GET https://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units={units}`
- By coordinates: `GET https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units={units}`

### Temperature Units
- `metric`: Celsius (°C)
- `imperial`: Fahrenheit (°F)

## Error Handling

The app handles the following errors gracefully:
- **Network Errors**: "Request timeout. Please check your internet connection."
- **City Not Found**: "City not found. Please try another city." (404)
- **Invalid API Key**: "Invalid API key. Please check your configuration." (401)
- **Server Errors**: "Failed to fetch weather data. Error: {status_code}"

## Code Quality

- Clean, readable code with meaningful variable names
- Comprehensive comments throughout
- Consistent formatting using Dart conventions
- No hardcoded values (using constants)
- Proper separation of concerns

## Troubleshooting

### Common Issues

1. **"API key not configured" error**:
   - Make sure you've added your API key to `lib/constants/api_config.dart`
   - Don't forget to save the file

2. **"City not found" error**:
   - Ensure the city name is spelled correctly
   - Try using the full city name (e.g., "New York" instead of just "York")

3. **App not starting**:
   - Run `flutter clean && flutter pub get && flutter run`
   - Check that you're using a compatible Flutter version (>=3.0.0)

4. **Favorites not saving**:
   - Ensure SharedPreferences is initialized (happens in `main()`)
   - Check that the app has proper permissions on your device

## Running on Windows (Desktop)

To run the Flutter app natively on your Windows laptop:

### Enable Windows Desktop Support

```powershell
flutter config --enable-windows-desktop
```

### Build Windows Support (one-time setup)

```powershell
cd "a:\Semester 5\Mobile Programming\Assignments\Weather app\weather_app"
flutter create .
```

### Run on Windows

```powershell
flutter run -d windows
```

### Build Windows Release Bundle

```powershell
flutter build windows --release
# Output folder: build\windows\runner\Release\
```

**Requirements**: Visual Studio with Desktop development workload, or MinGW.

## CI / Automated Builds

This repo includes a GitHub Actions workflow (`.github/workflows/flutter_ci.yml`) that automatically builds on push:
- **Android APK**: on Ubuntu runner, produces `app-release.apk`
- **Windows release bundle**: on Windows runner, produces build folder
- **iOS IPA**: on macOS runner, produces unsigned .ipa (sign separately or configure CI secrets)

### Trigger CI Manually

On GitHub: Actions → Flutter CI - Build Artifacts → Run workflow

## Final Checklist (Original Task Requirements)

- [x] Home/Search screen implemented (search by city, display search history)
- [x] Weather Details screen implemented with all required fields:
  - [x] City name
  - [x] Current temperature
  - [x] Weather description & main condition
  - [x] Feels-like temperature
  - [x] Humidity percentage
  - [x] Wind speed
  - [x] Sunrise and sunset times
  - [x] Local time (with timezone offset)
  - [x] Weather icon
- [x] Favorites screen implemented (save/remove, local persistence)
- [x] Settings screen implemented (Celsius / Fahrenheit toggle)
- [x] Navigation implemented using Navigator & MaterialPageRoute
- [x] State management via Riverpod (flutter_riverpod)
- [x] Local storage via SharedPreferences (singleton StorageService)
- [x] OpenWeatherMap Current Weather API integration (by city & coordinates)
- [x] API key configuration (placeholder in `lib/constants/api_config.dart`, added to `.gitignore`)
- [x] Error handling (network, timeouts, 401, 404, no internet)
- [x] Android APK buildable locally: `flutter build apk --release`
- [x] Android APK CI artifact available via GitHub Actions
- [x] Windows desktop configuration documented & buildable locally: `flutter build windows --release`
- [x] Windows CI artifact available via GitHub Actions
- [x] iOS build documented (unsigned IPA can be produced on macOS)
- [x] iOS CI artifact available via GitHub Actions (unsigned)
- [x] README.md updated with app description, features, setup, API usage, and final checklist
- [x] Code clean (no emoji, no AI-implication text)

## Future Enhancements

- GPS location-based weather
- Multi-language support
- Dark mode theme
- Weather forecasts (5-day, hourly)
- Weather alerts and notifications
- Unit tests and widget tests
- Weather comparisons between cities

## License

This project is created for educational purposes as part of Mobile Programming coursework.

## Support

For issues or questions, please refer to:
- Flutter Documentation: https://flutter.dev/docs
- Riverpod Documentation: https://riverpod.dev
- OpenWeatherMap API Support: https://openweathermap.org/find

## Author

Created for Semester 5 - Mobile Programming Assignment
