import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';

/// Provides access to the StorageService singleton instance throughout the app.
///
/// Riverpod manages the lifecycle of this provider, ensuring StorageService
/// is only instantiated once and shared across all screens and widgets.
final storageServiceProvider = Provider((ref) {
  return StorageService.instance;
});

/// Manages the current temperature unit preference (metric or imperial).
///
/// This StateProvider allows any widget to read the current temperature unit
/// and subscribe to changes. When the user toggles between Celsius/Fahrenheit
/// in settings, this provider notifies all listeners to rebuild with the new unit.
///
/// The initial value is read from StorageService (persisted from previous sessions).
final temperatureUnitProvider = StateProvider<String>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getTemperatureUnit();
});

/// Fetches weather data for a given city name.
///
/// This FutureProvider.family is parameterized by city name, allowing different
/// cities to have independent cached weather data. The provider automatically
/// watches temperatureUnitProvider, so when the user changes the temperature
/// unit, the weather data is re-fetched with the new unit.
///
/// Usage: ref.watch(weatherProvider('London'))
final weatherProvider =
    FutureProvider.family<WeatherModel, String>((ref, cityName) async {
  final unit = ref.watch(temperatureUnitProvider);
  return WeatherService.getWeatherByCity(
    cityName: cityName,
    units: unit,
  );
});

/// Fetches weather data using geographic coordinates (latitude/longitude).
///
/// Useful for future location-based features. Takes a record of latitude
/// and longitude as the parameter. Like weatherProvider, this respects
/// the current temperature unit setting.
///
/// Usage: ref.watch(weatherByCoordinatesProvider((latitude: 51.5, longitude: -0.1)))
final weatherByCoordinatesProvider =
    FutureProvider.family<WeatherModel, ({double latitude, double longitude})>(
        (ref, coords) async {
  final unit = ref.watch(temperatureUnitProvider);
  return WeatherService.getWeatherByCoordinates(
    latitude: coords.latitude,
    longitude: coords.longitude,
    units: unit,
  );
});

/// Provides the list of all favorite cities.
///
/// Any widget watching this provider will rebuild whenever the favorites
/// list changes (when a city is added or removed). Favorites are persisted
/// in device storage via StorageService.
final favoriteCitiesProvider = FutureProvider<List<String>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getFavoriteCities();
});

/// Checks whether a specific city is in the user's favorites.
///
/// This FutureProvider.family is parameterized by city name. It allows
/// widgets to independently check favorite status for different cities
/// and rebuild when the status changes.
///
/// Usage: ref.watch(isFavoriteProvider('London'))
final isFavoriteProvider =
    FutureProvider.family<bool, String>((ref, cityName) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.isFavorite(cityName);
});

/// Provider for search history
final searchHistoryProvider = FutureProvider<List<String>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getSearchHistory();
});
