import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

/// City suggestion model for autocomplete
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

  /// Display name for UI (e.g., "London, GB" or "New York, US")
  String get displayName {
    if (state != null && state!.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }

  @override
  String toString() => displayName;
}

/// Service for geocoding (city name to coordinates) via OpenWeatherMap Geocoding API
class GeocodingService {
  /// Get city suggestions by name (direct geocoding)
  /// Returns list of CitySuggestion sorted by relevance
  static Future<List<CitySuggestion>> getCitySuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      if (ApiConfig.apiKey == 'YOUR_API_KEY_HERE') {
        return [];
      }

      // Normalize query: trim for case-insensitive search
      final normalizedQuery = query.trim();
      final String url =
          '${ApiConfig.baseUrl}/geo/1.0/direct?q=$normalizedQuery&limit=10&appid=${ApiConfig.apiKey}';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Timeout'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Convert to CitySuggestion and remove duplicates
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

  /// Reverse geocoding: get city name from coordinates
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
