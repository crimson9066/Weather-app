import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';

/// Provider for StorageService singleton
final storageServiceProvider = Provider((ref) {
  return StorageService.instance;
});

/// Provider for the current temperature unit (metric or imperial)
final temperatureUnitProvider = StateProvider<String>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getTemperatureUnit();
});

/// Provider for fetching weather by city name
final weatherProvider =
    FutureProvider.family<WeatherModel, String>((ref, cityName) async {
  final unit = ref.watch(temperatureUnitProvider);
  return WeatherService.getWeatherByCity(
    cityName: cityName,
    units: unit,
  );
});

/// Provider for fetching weather by coordinates
final weatherByCoordinatesProvider = FutureProvider.family<WeatherModel,
    ({double latitude, double longitude})>((ref, coords) async {
  final unit = ref.watch(temperatureUnitProvider);
  return WeatherService.getWeatherByCoordinates(
    latitude: coords.latitude,
    longitude: coords.longitude,
    units: unit,
  );
});

/// Provider for favorite cities list
final favoriteCitiesProvider = FutureProvider<List<String>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getFavoriteCities();
});

/// Provider for checking if a city is favorite
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
