# Weather App - Setup Guide

## Prerequisites

- Flutter SDK 3.0 or later
- An OpenWeatherMap API key (free account at https://openweathermap.org/api)

## Initial Setup

### Step 1: Get an OpenWeatherMap API Key

1. Go to https://openweathermap.org/api
2. Create a free account and log in
3. Navigate to your API keys section
4. You'll find a default API key (or click "Generate" to create a new one)
5. Copy this key - you'll need it next

The free tier allows 60 API calls per minute and 1,000,000 calls per month, which is plenty for development and testing.

### Step 2: Configure the API Key

1. Open `lib/constants/api_config.dart`
2. Replace the placeholder with your actual API key:
   ```dart
   static const String apiKey = 'your_api_key_here';
   ```
3. Save the file

**Important**: The `api_config.dart` file is in `.gitignore` to prevent accidentally committing your API key to public repositories. Keep this file local only.

### Step 3: Install Dependencies

```bash
flutter pub get
```

This downloads all required packages: Riverpod (state management), HTTP (API calls), SharedPreferences (local storage), and intl (date formatting).

### Step 4: Run the App

For Windows development:
```bash
flutter run -d windows
```

For default device (Android/iOS):
```bash
flutter run
```

With verbose output for debugging:
```bash
flutter run -v
```

## Project Structure

```
lib/
├── main.dart                    # App entry point and navigation setup
├── pages/                       # App screens (full-page widgets)
│   ├── home_screen.dart        # City search with autocomplete
│   ├── weather_details_screen.dart # Detailed weather display
│   ├── favorites_screen.dart    # Saved favorite cities
│   └── settings_screen.dart     # Temperature unit preference
├── services/                    # Business logic
│   ├── weather_service.dart    # OpenWeatherMap API integration
│   ├── geocoding_service.dart  # City name suggestions
│   └── storage_service.dart    # Local data persistence
├── models/                      # Data structures
│   └── weather_model.dart      # Weather data model
├── providers/                   # Riverpod state management
│   └── weather_providers.dart  # App-wide state providers
├── widgets/                     # Reusable UI components
│   └── reusable_widgets.dart   # Common widgets
└── constants/
    └── api_config.dart         # API configuration
```

## Building for Production

### Android APK (Debug)
```bash
flutter build apk
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Android APK (Release - Optimized)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (For Google Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Build (Requires macOS)
```bash
flutter build ios --release
```

## Troubleshooting

### "API key not configured" Error
- Open `lib/constants/api_config.dart`
- Verify you've replaced the placeholder with your actual API key
- Check for no extra spaces in the key
- Run `flutter clean && flutter run`

### "City not found" Error
- Use the full city name (e.g., "New York" not "NY")
- Try different spellings
- Use English city names for best results

### App Crashes on Startup
```bash
flutter clean
flutter pub get
flutter run -v
```

### Dependencies Won't Install
```bash
flutter pub cache clean
flutter pub get
flutter pub upgrade
```

### Android Emulator Issues
```bash
# List available emulators
emulator -list-avds

# Start an emulator
emulator @emulator_name

# Then run the app
flutter run
```

## Code Organization

**Naming Conventions**:
- Dart files: `snake_case.dart`
- Classes: `PascalCase`
- Functions/variables: `camelCase`

**Folder Structure**:
- `pages/`: Full-page screens
- `services/`: API calls and business logic
- `models/`: Data structures
- `providers/`: State management with Riverpod
- `widgets/`: Reusable UI components
- `constants/`: Configuration values

All code includes proper documentation, meaningful variable names, comprehensive error handling, and null safety.
