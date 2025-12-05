import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages all local device storage operations using SharedPreferences.
///
/// This service implements the singleton pattern to ensure only one instance
/// manages device storage throughout the app's lifetime. It handles three main
/// data types: favorite cities (list), temperature unit preference (string),
/// and search history (list).
///
/// All data is stored as JSON strings in SharedPreferences and automatically
/// serialized/deserialized to Dart collections.
class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  StorageService._internal();

  static StorageService get instance => _instance;

  // Storage keys used in SharedPreferences
  static const String _favoritesKey = 'favorite_cities';
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _searchHistoryKey = 'search_history';

  late SharedPreferences _prefs;

  /// Initializes SharedPreferences. Must be called once at app startup
  /// before any storage operations. This is done in main.dart.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Retrieves the list of favorite city names.
  ///
  /// Returns an empty list if no favorites have been saved yet.
  Future<List<String>> getFavoriteCities() async {
    final jsonString = _prefs.getString(_favoritesKey);
    if (jsonString == null) return [];
    return List<String>.from(jsonDecode(jsonString));
  }

  /// Adds a city to the favorites list if not already present.
  ///
  /// Duplicates are automatically prevented. Returns true if the operation
  /// succeeded (city was added or was already in favorites).
  Future<bool> addFavorite(String cityName) async {
    final favorites = await getFavoriteCities();
    if (!favorites.contains(cityName)) {
      favorites.add(cityName);
      return _prefs.setString(_favoritesKey, jsonEncode(favorites));
    }
    return true;
  }

  /// Removes a city from the favorites list.
  ///
  /// If the city is not in favorites, the list remains unchanged.
  Future<bool> removeFavorite(String cityName) async {
    final favorites = await getFavoriteCities();
    favorites.removeWhere((city) => city == cityName);
    return _prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  /// Checks whether a city is currently in the favorites list.
  Future<bool> isFavorite(String cityName) async {
    final favorites = await getFavoriteCities();
    return favorites.contains(cityName);
  }

  /// Gets the user's temperature unit preference.
  ///
  /// Returns 'metric' (Celsius) by default if no preference has been set.
  /// Can be 'metric' or 'imperial'.
  String getTemperatureUnit() {
    return _prefs.getString(_temperatureUnitKey) ?? 'metric';
  }

  /// Sets the user's temperature unit preference.
  ///
  Future<bool> setTemperatureUnit(String unit) {
    return _prefs.setString(_temperatureUnitKey, unit);
  }

  /// Get search history
  Future<List<String>> getSearchHistory() async {
    final jsonString = _prefs.getString(_searchHistoryKey);
    if (jsonString == null) return [];
    return List<String>.from(jsonDecode(jsonString));
  }

  /// Add city to search history
  Future<bool> addToSearchHistory(String cityName) async {
    final history = await getSearchHistory();
    // Remove if already exists to avoid duplicates
    history.removeWhere((city) => city == cityName);
    // Add to beginning of list
    history.insert(0, cityName);
    // Keep only last 10 searches
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
    return _prefs.setString(_searchHistoryKey, jsonEncode(history));
  }

  /// Remove a city from search history
  Future<bool> removeFromSearchHistory(String cityName) async {
    final history = await getSearchHistory();
    history.removeWhere((city) => city == cityName);
    return _prefs.setString(_searchHistoryKey, jsonEncode(history));
  }

  /// Clear search history
  Future<bool> clearSearchHistory() {
    return _prefs.remove(_searchHistoryKey);
  }
}
