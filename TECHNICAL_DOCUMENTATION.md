# Weather App - Technical Documentation

## Architecture Overview

The Weather App follows a clean, layered architecture:

```
lib/
├── main.dart                  # App initialization and theme setup
├── pages/                     # Screens (top-level widgets)
├── services/                  # Business logic and API integration
├── models/                    # Data structures from API responses
├── providers/                 # Riverpod state management
├── widgets/                   # Reusable UI components
└── constants/                 # Configuration (API keys, endpoints)
```

This structure separates concerns: pages handle UI layout, services handle external communication, and providers manage state flow between them.

## State Management: Riverpod

The app uses [Riverpod](https://riverpod.dev/) for state management because it provides:
- Type-safe dependency injection
- Automatic caching and lifecycle management
- Simple invalidation for refreshing data

### Provider Types Used

**Provider** - Synchronous read-only access:
```dart
final storageServiceProvider = Provider((ref) {
  return StorageService.instance;
});
```

**StateProvider** - Mutable state that can be updated:
```dart
final temperatureUnitProvider = StateProvider<String>((ref) {
  return storage.getTemperatureUnit();
});
```

**FutureProvider** - Async data that auto-caches:
```dart
final favoriteCitiesProvider = FutureProvider<List<String>>((ref) async {
  return storage.getFavoriteCities();
});
```

**FutureProvider.family** - Parameterized async data:
```dart
final weatherProvider = FutureProvider.family<WeatherModel, String>((ref, cityName) async {
  return WeatherService.getWeatherByCity(cityName: cityName, units: unit);
});
```

### Provider Invalidation

When data changes (e.g., user adds a favorite), we invalidate related providers to force a refresh:

```dart
// In FavoriteCard delete button:
ref.invalidate(favoriteCitiesProvider);
ref.invalidate(isFavoriteProvider(cityName));
```

This triggers any widgets watching these providers to rebuild with fresh data.

## Data Flow

```
User Action (Search, Add Favorite, etc.)
    ↓
Widget reads from Riverpod provider
    ↓
Provider calls Service (WeatherService, GeocodingService, StorageService)
    ↓
Service makes API call or accesses local storage
    ↓
Response is cached in provider
    ↓
Widget rebuilds with new data
```

## Services Layer

### WeatherService
Communicates with the OpenWeatherMap Current Weather API. Returns a `WeatherModel` with comprehensive weather data.

**Key methods:**
- `getWeatherByCity(cityName, units)` - Fetch by city name
- `getWeatherByCoordinates(latitude, longitude, units)` - Fetch by coordinates

**Error handling:** Throws `WeatherServiceException` with user-friendly messages for common errors (invalid API key, city not found, network timeout, etc.).

### GeocodingService
Communicates with the OpenWeatherMap Geocoding API to provide city name suggestions for autocomplete.

**Key methods:**
- `getCitySuggestions(query)` - Returns up to 10 city suggestions; duplicates are removed
- `getCityFromCoordinates(lat, lon)` - Reverse geocoding (not currently used but available for future GPS features)

**Design decision:** Returns empty list on errors instead of throwing exceptions. This ensures the autocomplete dropdown doesn't crash if the API is temporarily down - users can still type freely, just without suggestions.

### StorageService
Manages local device storage using SharedPreferences. Implements the singleton pattern to ensure one instance manages all storage.

**Key methods:**
- `getFavoriteCities()` / `addFavorite()` / `removeFavorite()` / `isFavorite()` - Favorite cities management
- `getTemperatureUnit()` / `setTemperatureUnit()` - User preference storage
- `getSearchHistory()` / `addToSearchHistory()` / `removeFromSearchHistory()` - Recent searches tracking

**Design decision:** Data is stored as JSON strings in SharedPreferences. This allows storing lists without external database dependencies.

## Models

### WeatherModel
Represents the complete weather data response from the OpenWeatherMap API. Contains 20 fields:

**Temperature & Comfort:**
- `temperature` - Current temp in user's chosen unit
- `feelsLike` - Perceived temperature due to wind/humidity
- `dewPoint` - Dew point temperature (optional)

**Atmospheric Conditions:**
- `humidity` - Percentage (0-100)
- `pressure` - Atmospheric pressure in hPa
- `visibility` - Maximum visibility distance in meters
- `cloudiness` - Cloud coverage percentage

**Wind Data:**
- `windSpeed` - Wind speed in current unit
- `windGust` - Maximum wind gust (optional)
- `windDegree` - Wind direction (0-360, optional)

**Location & Time:**
- `cityName` - City name from API
- `countryCode` - ISO country code
- `latitude` / `longitude` - Geographic coordinates
- `timezone` - Timezone offset in seconds
- `dateTime` - Time data was fetched
- `sunrise` / `sunset` - Unix timestamps

**Presentation:**
- `weatherMain` - Main category (Rain, Clear, Clouds, Snow, Thunderstorm)
- `description` - Human-readable description
- `iconUrl` - URL to weather icon from OpenWeatherMap

## Pages (Screens)

### HomeScreen
**Purpose:** City search entry point with autocomplete and search history.

**State Management:** ConsumerStatefulWidget managing:
- `_searchController` - TextField input
- `_suggestions` - Current autocomplete suggestions
- `_showSuggestions` - Whether to display dropdown
- `_isLoading` - Dropdown loading state

**Flow:**
1. User types city name
2. `_onSearchChanged()` queries GeocodingService
3. Suggestions appear in Material dropdown menu (10 items max)
4. User taps a suggestion or presses Enter
5. `_navigateToDetails()` navigates to WeatherDetailsScreen with selected city
6. Search is added to history (stored in SharedPreferences)

**Design decisions:**
- Real-time suggestions as user types (with debouncing via Future)
- Search history shown as InputChips - tappable for quick re-search, deletable
- Dropdown overlay respects Material Design 3 styling

### WeatherDetailsScreen
**Purpose:** Display comprehensive weather data for a selected city.

**State Management:** ConsumerStatefulWidget managing:
- `_tabIndex` - Currently selected tab (Current/Atmosphere/Wind)

**UI Structure:**
1. **Hero Section** - Gradient background based on weather type, large temperature display
2. **City & Time Info** - Location name, local time, country flag
3. **Tab Navigation** - Three tabs with different data:
   - Current: Temperature, feels-like, sunrise/sunset, condition, dew point
   - Atmosphere: Humidity, pressure, visibility, cloudiness
   - Wind: Speed, gust, direction

**Animations:**
- `TweenAnimationBuilder` scales weather icon from 0 to 1 (800ms)
- Temperature counter animates from 0 to actual value (1200ms)
- Creates smooth entry effect for data

**Favorite Toggle:** Star icon in AppBar - uses `isFavoriteProvider` to check status and invalidates on change.

### FavoritesScreen
**Purpose:** Display all saved favorite cities with weather previews.

**UI:** Grid or list of FavoriteCard widgets:
- Weather-specific gradient background (sunny=orange, rainy=blue, cloudy=gray, snowy=light blue, stormy=dark)
- City name, current temperature, weather condition
- Delete button to remove from favorites
- Tappable to navigate to details

**Animation:** Icon scales on card (600ms) for visual polish.

**State Management:** ConsumerWidget watching `favoriteCitiesProvider` to display all favorites.

### SettingsScreen
**Purpose:** User preferences (currently just temperature unit).

**Current Features:**
- Radio buttons to toggle between Celsius and Fahrenheit
- Changes persist to SharedPreferences via `temperatureUnitProvider`

**Design note:** Uses deprecated `RadioListTile` - Flutter recommends using `SegmentedButton` or custom implementation for new apps. This is noted in the code.

**Future Enhancement Opportunities:**
- Dark mode toggle
- Notification settings
- About section with version info
- API usage statistics
- Data refresh interval settings

## Styling & Theme

### Material Design 3 Setup
The app uses `ColorScheme.fromSeed(seedColor: Colors.blue)` which generates a complete color scheme from a single seed color.

**Theme Customizations:**
- **Cards:** 16px rounded corners, no elevation (flat design)
- **Buttons:** 12px rounded corners, consistent padding
- **Input Fields:** 12px rounded corners, material outline borders
- **AppBar:** No elevation, centered title

All colors use the generated `colorScheme` properties (e.g., `colorScheme.primary`, `colorScheme.onSurface`) ensuring consistency and respecting user system settings.

### Weather-Specific Gradients
The favorites and details screens use gradients that reflect the weather condition:

```dart
LinearGradient _getWeatherGradient(String weatherMain) {
  switch (weatherMain.toLowerCase()) {
    case 'clear':
      return LinearGradient(colors: [Colors.orange, Colors.amber]);
    case 'rain':
      return LinearGradient(colors: [Colors.blue, Colors.blueAccent]);
    case 'clouds':
      return LinearGradient(colors: [Colors.grey, Colors.blueGrey]);
    case 'snow':
      return LinearGradient(colors: [Colors.lightBlue, Colors.cyan]);
    case 'thunderstorm':
      return LinearGradient(colors: [Colors.grey[800], Colors.purple]);
    default:
      return LinearGradient(colors: [Colors.teal, Colors.tealAccent]);
  }
}
```

This visual feedback immediately communicates the weather type to users.

## API Integration

### OpenWeatherMap Endpoints

**Current Weather API:**
```
GET https://api.openweathermap.org/data/2.5/weather?q={city}&units={metric|imperial}&appid={apiKey}
```

Response includes: temperature, feels-like, humidity, pressure, wind, clouds, visibility, sunrise/sunset, etc.

**Geocoding API:**
```
GET https://api.openweathermap.org/geo/1.0/direct?q={cityName}&limit=10&appid={apiKey}
```

Response is array of matching cities with coordinates.

### Error Handling

**WeatherService** provides context-aware error messages:
- `API key not configured` - User hasn't set up their API key
- `City not found` - Search returned no results
- `Request timeout` - Network is slow or unavailable
- Server errors (5xx) with status code

**GeocodingService** silently fails:
- Returns empty list if API is down
- Returns empty list if query is empty
- Handles timeouts gracefully

This graceful degradation ensures the app stays usable even when APIs fail.

## Testing

### Widget Tests (`test/widget_test.dart`)
Tests verify:
- App launches without errors
- Bottom navigation bar exists with 3 tabs
- Navigation between tabs works correctly
- Tab labels display properly

Run tests:
```bash
flutter test
```

### Manual Testing Checklist
- [ ] Search for various city names (exact, partial, special characters)
- [ ] Verify weather data displays correctly for different cities
- [ ] Test temperature unit toggle changes all displays
- [ ] Add/remove favorites, verify persistence
- [ ] Clear app data and reload (favorites should persist)
- [ ] Test with no internet connection (graceful error messages)
- [ ] Verify search history is saved and removable

## Dependencies

**State Management:**
- `flutter_riverpod: ^2.4.0` - Type-safe reactive programming

**Networking:**
- `http: ^1.1.0` - HTTP client for API calls (10-second timeout)

**Storage:**
- `shared_preferences: ^2.2.2` - Device local storage for favorites and preferences

**Utilities:**
- `intl: ^0.19.0` - Internationalization (date/time formatting by timezone)

**Flutter SDK:**
- Minimum 3.0.0 for null safety and Material Design 3 support

## Building & Deployment

### Debug Build (Development)
```bash
flutter run -d windows       # Windows
flutter run                  # Default device
```

### Release Build
```bash
flutter build apk --release          # Android
flutter build appbundle --release    # Google Play Store
flutter build ios --release          # iOS
```

Release builds apply code shrinking, resource optimization, and obfuscation for smaller, faster apps.

## Performance Considerations

1. **Provider Caching** - Riverpod automatically caches weather data. Repeated searches for the same city within a session don't hit the API again.

2. **Autocomplete Debouncing** - Geocoding requests are sent as the user types, but only for non-empty, trimmed queries.

3. **List Deduplication** - Geocoding results are deduplicated to prevent duplicate cities in the dropdown.

4. **Lazy Loading** - Screens only fetch data when navigated to; unused screens don't consume resources.

5. **Image Caching** - Weather icons from OpenWeatherMap are cached by the HTTP client automatically.

## Future Enhancement Ideas

1. **Device Location** - Integrate GPS to show weather for user's current location
2. **Hourly Forecast** - Show 24-hour weather forecast using extended API
3. **Dark Mode** - Add theme toggle in settings
4. **Search Filter** - Filter favorites by country or weather condition
5. **Weather Alerts** - Notify user when severe weather is forecasted
6. **Data Visualization** - Charts showing temperature/humidity trends
7. **Multiple Languages** - Localization using intl package
8. **Background Updates** - Periodic updates of favorite city weather

## Troubleshooting

**App crashes on startup:**
- Ensure SharedPreferences has been initialized in main()
- Check that StorageService.instance.init() is called before runApp()

**Autocomplete dropdown not showing:**
- Verify API key is configured
- Check network connectivity
- GeocodingService returns empty list on all errors

**Weather data shows wrong temperature unit:**
- Clear app cache: `flutter clean`
- Delete app and reinstall
- Check StorageService.getTemperatureUnit() returns correct value

**Favorites not persisting:**
- Ensure StorageService is initialized
- Check that addFavorite() completes successfully (check return value)
- Manually clear SharedPreferences if corrupted

## Code Organization Principles

1. **Single Responsibility** - Each class has one job (WeatherService does API calls only)
2. **Dependency Injection** - Services are injected via Riverpod, not created in widgets
3. **Error Handling** - All API calls wrap errors in custom exceptions or graceful fallbacks
4. **Comments** - Why code exists, not what it does (code should be self-documenting)
5. **Naming** - Clear, descriptive names (\_getWeatherGradient instead of \_getGradient)
