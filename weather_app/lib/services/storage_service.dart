import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage operations
class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  StorageService._internal();

  static StorageService get instance => _instance;

  static const String _favoritesKey = 'favorite_cities';
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _searchHistoryKey = 'search_history';

  late SharedPreferences _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get list of favorite cities
  Future<List<String>> getFavoriteCities() async {
    final jsonString = _prefs.getString(_favoritesKey);
    if (jsonString == null) return [];
    return List<String>.from(jsonDecode(jsonString));
  }

  /// Add a city to favorites
  Future<bool> addFavorite(String cityName) async {
    final favorites = await getFavoriteCities();
    if (!favorites.contains(cityName)) {
      favorites.add(cityName);
      return _prefs.setString(_favoritesKey, jsonEncode(favorites));
    }
    return true;
  }

  /// Remove a city from favorites
  Future<bool> removeFavorite(String cityName) async {
    final favorites = await getFavoriteCities();
    favorites.removeWhere((city) => city == cityName);
    return _prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  /// Check if a city is in favorites
  Future<bool> isFavorite(String cityName) async {
    final favorites = await getFavoriteCities();
    return favorites.contains(cityName);
  }

  /// Get temperature unit setting (metric or imperial)
  String getTemperatureUnit() {
    return _prefs.getString(_temperatureUnitKey) ?? 'metric';
  }

  /// Set temperature unit (metric or imperial)
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
