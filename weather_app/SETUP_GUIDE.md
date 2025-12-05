# Weather App - Complete Setup Guide

## Project Overview

This is a production-ready Flutter Weather Application with:
- Multi-page navigation (Home, Weather Details, Favorites, Settings)
- Real-time weather API integration
- Local storage with SharedPreferences
- Riverpod state management
- Temperature unit toggle (°C/°F)
- Favorites management
- Search history
- Comprehensive error handling
- Clean, modular code architecture

## Project Structure

```
weather_app/
├── lib/
│   ├── main.dart                           # App entry point & main navigation
│   ├── constants/
│   │   └── api_config.dart                # API configuration (needs API key)
│   ├── models/
│   │   └── weather_model.dart             # Weather data model
│   ├── services/
│   │   ├── weather_service.dart           # OpenWeatherMap API client
│   │   └── storage_service.dart           # Local storage management
│   ├── providers/
│   │   └── weather_providers.dart         # Riverpod providers
│   ├── pages/
│   │   ├── home_screen.dart               # Search & home page
│   │   ├── weather_details_screen.dart    # Weather details display
│   │   ├── favorites_screen.dart          # Favorites management
│   │   └── settings_screen.dart           # Settings & preferences
│   └── widgets/
│       └── reusable_widgets.dart          # Common UI components
├── android/                                # Android build configuration
├── ios/                                    # iOS build configuration
├── pubspec.yaml                            # Dependencies & project metadata
├── README.md                               # User documentation
├── SETUP_GUIDE.md                         # This file
├── .gitignore                              # Git ignore rules
├── analysis_options.yaml                   # Code analysis configuration
└── .metadata                               # Flutter metadata

## Step-by-Step Setup

### 1. Get an OpenWeatherMap API Key (IMPORTANT!)

**This is the FIRST thing you need to do:**

1. Go to https://openweathermap.org/api
2. Click "Sign Up" and create a free account
3. Go to your API keys section
4. You'll see a default API key (or click "Generate" to create one)
5. Copy this API key - you'll need it in the next step

**Note**: Free tier allows 60 calls/minute and 1,000,000 calls/month - plenty for testing!

### 2. Configure the API Key

1. Open `lib/constants/api_config.dart`
2. Find this line:
   ```dart
   static const String apiKey = 'YOUR_API_KEY_HERE';
   ```
3. Replace `'YOUR_API_KEY_HERE'` with your actual API key:
   ```dart
   static const String apiKey = 'abc123def456ghi789jkl012mno345pqr';
   ```
4. **Save the file** (Ctrl+S or Cmd+S)

**⚠️ IMPORTANT**: Never commit your API key to public repositories! The `api_config.dart` file is listed in `.gitignore` for production use.

### 3. Install Flutter (if not already installed)

```bash
# Download Flutter from https://flutter.dev/docs/get-started/install
# Or use a package manager:

# macOS (Homebrew)
brew install flutter

# Windows (Chocolatey)
choco install flutter

# Linux
# Follow: https://flutter.dev/docs/get-started/install/linux
```

### 4. Get Dependencies

```bash
cd weather_app
flutter pub get
```

This downloads all required packages:
- `flutter_riverpod` - State management
- `http` - API calls
- `shared_preferences` - Local storage
- `intl` - Date/time formatting

### 5. Run the App

**On Android Emulator/Device**:
```bash
flutter run
```

**On iOS Simulator** (macOS only):
```bash
flutter run -d macos
# or
flutter run -d iPhone-simulator
```

**With verbose output** (for debugging):
```bash
flutter run -v
```

## Building for Production

### Android APK Build

**Debug APK** (for testing):
```bash
flutter build apk
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

**Release APK** (optimized, for distribution):
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle** (for Google Play Store):
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Build (macOS required)

**Debug Build**:
```bash
flutter build ios
# Output: build/ios/iphoneos/Runner.app
```

**Release Build**:
```bash
flutter build ios --release
```

**Create .ipa for TestFlight/Distribution**:
```bash
flutter build ios --release
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -derivedDataPath ../build/ios_release -arch arm64 build
```

## App Features & How to Use

### 1. Home/Search Screen
- **Search**: Enter a city name and press Enter or tap the Search button
- **History**: Your recent searches appear below
- **Example cities**: New York, London, Tokyo, Mumbai, etc.

### 2. Weather Details Screen
Shows comprehensive weather info:
- Temperature with "Feels Like" value
- Weather description (Rainy, Cloudy, Clear, etc.)
- Humidity percentage
- Wind speed
- Sunrise and sunset times
- Local time in the city's timezone
- **Favorite button**: Star icon to save/unsave from favorites

### 3. Favorites Screen
- View all saved favorite cities
- Quick weather peek on each card
- Tap any city to see full details
- Delete button (trash icon) to remove from favorites

### 4. Settings Screen
- **Temperature Unit**: Switch between Celsius (°C) and Fahrenheit (°F)
- **About**: App version and features
- **API Info**: Details about OpenWeatherMap

## Troubleshooting

### Issue: "API key not configured" error

**Solution**:
1. Open `lib/constants/api_config.dart`
2. Check that you've replaced `'YOUR_API_KEY_HERE'` with your actual API key
3. Make sure there are no spaces in the key
4. Save the file
5. Run `flutter clean && flutter run`

### Issue: "City not found" error

**Solution**:
- Use the full city name (e.g., "New York" not "NY")
- Try alternative spellings
- Cities with special characters might need adjustment
- Use English city names for best results

### Issue: App crashes on startup

**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Or with verbose output for more info
flutter run -v
```

### Issue: Can't find iOS simulator

**Solution** (macOS):
```bash
# List available simulators
xcrun simctl list devices

# Launch a specific simulator
open -a Simulator

# Run app on specific device
flutter run -d "iPhone 14"
```

### Issue: Android emulator not starting

**Solution**:
```bash
# List available emulators
emulator -list-avds

# Start an emulator
emulator @emulator_name

# Then run the app
flutter run
```

### Issue: Dependencies not installing

**Solution**:
```bash
# Clear Pub cache
flutter pub cache clean

# Get fresh dependencies
flutter pub get

# Update dependencies
flutter pub upgrade
```

## Code Organization & Standards

### File Naming Conventions
- **Dart files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Functions/variables**: `camelCase`

### Folder Structure Rationale

```
lib/
├── pages/           # Entire screen widgets (full-page UI)
├── services/        # Business logic & API calls
├── models/          # Data structure definitions
├── providers/       # Riverpod state management
├── widgets/         # Reusable UI components
└── constants/       # Configuration & constants
```

### Code Quality

All code includes:
- Comments explaining complex logic
- Meaningful variable names
- Proper error handling
- Null safety enabled
- Follow Dart style guide

## API Reference

### OpenWeatherMap Endpoints

**By City Name**:
```
GET https://api.openweathermap.org/data/2.5/weather
Parameters:
  - q: City name
  - appid: Your API key
  - units: "metric" (°C) or "imperial" (°F)

Example:
https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_KEY&units=metric
```

**By Coordinates**:
```
GET https://api.openweathermap.org/data/2.5/weather
Parameters:
  - lat: Latitude
  - lon: Longitude
  - appid: Your API key
  - units: "metric" or "imperial"

Example:
https://api.openweathermap.org/data/2.5/weather?lat=51.5074&lon=-0.1278&appid=YOUR_KEY&units=metric
```

## Deployment Checklist

Before deploying to production:

- [ ] API key is correctly configured
- [ ] Tested on multiple cities
- [ ] Tested offline error handling
- [ ] Settings (C/F toggle) works
- [ ] Favorites save and persist
- [ ] Search history works
- [ ] All screens navigate properly
- [ ] Error messages are user-friendly
- [ ] App handles network timeouts
- [ ] App closes cleanly without crashes
- [ ] APK/IPA build completes successfully
- [ ] App icon and branding are correct (optional)
- [ ] Removed debug logs (optional)

## Performance Tips

1. **Lazy Load Data**: Weather data is cached with Riverpod
2. **Minimize API Calls**: Use favorites to avoid redundant searches
3. **Local Storage**: Favorites and settings stored locally
4. **Efficient UI**: Uses `const` constructors and proper rebuilds

## Future Enhancement Ideas

- 🔄 Add weather forecast (5-day, hourly)
- 📍 GPS location-based weather
- 🌍 Multi-language support
- 🌙 Dark mode theme
- 📢 Weather alerts/notifications
- 📊 Weather comparison between cities
- 🗺️ Weather maps integration
- ⚡ Offline caching of weather data

## Testing the App

### Manual Testing Checklist

```
Search Functionality:
 - Search for valid city
 - Search for invalid city
 - Search with empty input
 - Check search history is saved
 - Click history item

Weather Details:
 - Verify all info displays
 - Check local time is correct
 - Verify temperature units
 - Check sunrise/sunset times
 - Test favorite button

Favorites:
 - Add city to favorites
 - Remove from favorites
 - Navigate to favorite city
 - Verify data persists on restart

Settings:
 - Toggle C/F
 - Verify weather updates with unit change
 - Check settings persist

Error Handling:
 - Test offline (airplane mode)
 - Invalid API key
 - Server errors
 - Slow network (Settings > Developer > Network throttling)
```

## Questions & Support

- **Flutter Docs**: https://flutter.dev/docs
- **Riverpod Docs**: https://riverpod.dev
- **OpenWeatherMap API**: https://openweathermap.org/find
- **Dart Language**: https://dart.dev/guides

## License

Educational project for Mobile Programming coursework.

---

**Happy coding!**

For any issues or questions, refer to the main README.md or the troubleshooting section above.
