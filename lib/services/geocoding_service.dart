import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

/// Represents a city suggestion for autocomplete functionality.
///
/// This model is returned from the Geocoding API and includes the city name,
/// optional state/province, country code, and geographic coordinates. The
/// displayName property formats this into a user-friendly string for UI display.
class CitySuggestion {
  final String name;
  final String? state;
  final String country;
  final double latitude;
  final double longitude;

  CitySuggestion({
    required this.name,
    this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  /// Formats the suggestion for display (e.g., "London, GB" or "New York, US")
  ///
  /// Includes state if available, otherwise just city name and country code.
  String get displayName {
    if (state != null && state!.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }

  @override
  String toString() => displayName;
}

/// Integrates with OpenWeatherMap Geocoding API to provide city suggestions.
///
/// This service handles city name lookups (direct geocoding) to power the
/// autocomplete dropdown in the home screen. It communicates with the
/// Geocoding API endpoint and handles deduplication of results to provide
/// clean, unique suggestions to the user.
class GeocodingService {
  /// Fetches city suggestions matching the given query string.
  ///
  /// Calls the OpenWeatherMap Geocoding API with direct geocoding to find
  /// matching cities. Results are deduplicated (same city name + country
  /// counted as one suggestion) and limited to 10 results for UI performance.
  ///
  /// Returns an empty list if the query is empty, API key is not configured,
  /// the network request fails, or the API returns an error. This graceful
  /// fallback ensures the app continues to work even if suggestions fail.
  static Future<List<CitySuggestion>> getCitySuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      if (ApiConfig.apiKey == 'YOUR_API_KEY_HERE') {
        return [];
      }

      // Trim whitespace for case-insensitive search
      final normalizedQuery = query.trim();
      final String url =
          '${ApiConfig.baseUrl}/geo/1.0/direct?q=$normalizedQuery&limit=10&appid=${ApiConfig.apiKey}';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Timeout'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Deduplicate results - if two cities have the same name and country,
        // only keep the first occurrence. This prevents duplicate entries
        // in the dropdown when multiple results come back.
        final suggestions = <CitySuggestion>[];
        final seen = <String>{};

        for (final item in data) {
          final key = '${item['name']}_${item['country']}';
          if (!seen.contains(key)) {
            seen.add(key);
            suggestions.add(
              CitySuggestion(
                name: item['name'] ?? '',
                state: item['state'],
                country: item['country'] ?? 'Unknown',
                latitude: (item['lat'] ?? 0).toDouble(),
                longitude: (item['lon'] ?? 0).toDouble(),
              ),
            );
          }
        }

        return suggestions;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Performs reverse geocoding to find the city name for given coordinates.
  ///
  /// Given latitude and longitude, queries the Geocoding API to find the
  /// nearest city. This is useful for future location-based features
  /// (e.g., device GPS integration). Returns null if the lookup fails.
  static Future<String?> getCityFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      if (ApiConfig.apiKey == 'YOUR_API_KEY_HERE') {
        return null;
      }

      final String url =
          '${ApiConfig.baseUrl}/geo/1.0/reverse?lat=$latitude&lon=$longitude&limit=1&appid=${ApiConfig.apiKey}';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Timeout'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data[0]['name'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
